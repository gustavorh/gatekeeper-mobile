import '../utils/result.dart';

/// Abstract interface for API operations
abstract class ApiClient {
  /// Perform a GET request
  Future<Result<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Perform a POST request
  Future<Result<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  });

  /// Perform a PATCH request
  Future<Result<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  });

  /// Perform a PUT request
  Future<Result<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  });

  /// Perform a DELETE request
  Future<Result<Map<String, dynamic>>> delete(
    String endpoint, {
    Map<String, String>? headers,
  });
}
