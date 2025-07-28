import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/auth_credentials.dart';

/// Abstract interface for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Login with credentials
  Future<Result<LoginResponseModel>> login(AuthCredentials credentials);

  /// Get current user profile
  Future<Result<UserModel>> getCurrentUser();

  /// Refresh authentication token
  Future<Result<String>> refreshToken();
}

/// Implementation of AuthRemoteDataSource using ApiClient
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Result<LoginResponseModel>> login(AuthCredentials credentials) async {
    try {
      final result = await _apiClient.post(AppConfig.loginEndpoint, {
        'rut': credentials.cleanRut,
        'password': credentials.password,
      });

      return result.when(
        success: (data) {
          try {
            final loginResponse = LoginResponseModel.fromJson(data);
            return Success(loginResponse);
          } catch (e) {
            return Error(ServerFailure('Error parsing login response: $e'));
          }
        },
        error: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(NetworkFailure('Login request failed: $e'));
    }
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final result = await _apiClient.get(AppConfig.profileEndpoint);

      return result.when(
        success: (data) {
          try {
            // Handle nested response structure
            final userData = data['data'] ?? data;
            final userModel = UserModel.fromJson(userData);
            return Success(userModel);
          } catch (e) {
            return Error(ServerFailure('Error parsing user data: $e'));
          }
        },
        error: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(NetworkFailure('Get user request failed: $e'));
    }
  }

  @override
  Future<Result<String>> refreshToken() async {
    try {
      final result = await _apiClient.post('/auth/refresh', {});

      return result.when(
        success: (data) {
          final token = data['token'] as String?;
          if (token != null) {
            return Success(token);
          } else {
            return Error(const ServerFailure('No token in refresh response'));
          }
        },
        error: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(NetworkFailure('Token refresh failed: $e'));
    }
  }
}
