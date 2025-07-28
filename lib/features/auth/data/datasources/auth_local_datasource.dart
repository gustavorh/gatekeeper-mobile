import '../../../../core/config/app_config.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

/// Abstract interface for authentication local data source
abstract class AuthLocalDataSource {
  /// Get stored authentication token
  Future<String?> getToken();

  /// Store authentication token
  Future<bool> setToken(String token);

  /// Remove stored authentication token
  Future<bool> removeToken();

  /// Check if token exists
  Future<bool> hasToken();

  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<bool> setCachedUser(UserModel user);

  /// Remove cached user data
  Future<bool> removeCachedUser();
}

/// Implementation of AuthLocalDataSource using LocalStorageService
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService _localStorage;

  AuthLocalDataSourceImpl(this._localStorage);

  @override
  Future<String?> getToken() async {
    return await _localStorage.getString(AppConfig.tokenKey);
  }

  @override
  Future<bool> setToken(String token) async {
    return await _localStorage.setString(AppConfig.tokenKey, token);
  }

  @override
  Future<bool> removeToken() async {
    return await _localStorage.remove(AppConfig.tokenKey);
  }

  @override
  Future<bool> hasToken() async {
    return await _localStorage.containsKey(AppConfig.tokenKey);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await _localStorage.getString(AppConfig.userKey);
      if (userJson != null) {
        // In a real app, you'd parse JSON here
        // For now, we'll return null and fetch from API
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setCachedUser(UserModel user) async {
    try {
      // In a real app, you'd serialize to JSON here
      // For now, we'll just return true
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeCachedUser() async {
    return await _localStorage.remove(AppConfig.userKey);
  }
}
