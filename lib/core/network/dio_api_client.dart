import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/failures.dart';
import '../storage/local_storage_service.dart';
import '../utils/result.dart';
import 'api_client.dart';

/// Dio implementation of ApiClient
class DioApiClient implements ApiClient {
  final Dio _dio;
  final LocalStorageService _localStorage;

  DioApiClient(this._dio, this._localStorage) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor for automatic token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = await _localStorage.getString(AppConfig.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 unauthorized errors
          if (error.response?.statusCode == 401) {
            // Clear stored token on unauthorized
            await _localStorage.remove(AppConfig.tokenKey);
            // You could also trigger a logout event here
          }
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return Success(_parseResponse(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return Success(_parseResponse(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return Success(_parseResponse(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return Success(_parseResponse(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
      return Success(_parseResponse(response));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  /// Parse the response data
  Map<String, dynamic> _parseResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    // If response is not a Map, wrap it
    return {'data': response.data};
  }

  /// Handle Dio errors and convert them to Failures
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Tiempo de conexión agotado');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const NetworkFailure('Solicitud cancelada');

      case DioExceptionType.connectionError:
        return const NetworkFailure('Error de conexión');

      case DioExceptionType.unknown:
      default:
        return NetworkFailure('Error de red: ${error.message}');
    }
  }

  /// Handle bad response errors (4xx, 5xx)
  Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Error del servidor';

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message, code: '400');
      case 401:
        return AuthFailure('No autorizado', code: '401');
      case 403:
        return AuthFailure('Acceso prohibido', code: '403');
      case 404:
        return ServerFailure('Recurso no encontrado', code: '404');
      case 500:
        return ServerFailure('Error interno del servidor', code: '500');
      default:
        return ServerFailure(message, code: statusCode?.toString());
    }
  }
}
