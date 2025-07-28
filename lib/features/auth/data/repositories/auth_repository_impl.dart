import 'dart:async';

import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final StreamController<AuthenticationState> _authStateController;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource)
    : _authStateController = StreamController<AuthenticationState>.broadcast();

  @override
  Future<Result<User>> login(AuthCredentials credentials) async {
    try {
      // Set auth state to checking
      _authStateController.add(AuthenticationState.checking);

      // Attempt login through remote data source
      final loginResult = await _remoteDataSource.login(credentials);

      return loginResult.when(
        success: (loginResponse) async {
          // Check if login was successful
          if (loginResponse.success == true &&
              loginResponse.token != null &&
              loginResponse.user != null) {
            // Store token locally
            await _localDataSource.setToken(loginResponse.token!);

            // Cache user data
            await _localDataSource.setCachedUser(loginResponse.user!);

            // Convert to domain entity
            final user = loginResponse.user!.toEntity();

            // Update auth state
            _authStateController.add(AuthenticationState.authenticated);

            return Success(user);
          } else {
            // Login failed
            _authStateController.add(AuthenticationState.unauthenticated);
            return Error(AuthFailure(loginResponse.message ?? 'Login failed'));
          }
        },
        error: (failure) {
          _authStateController.add(AuthenticationState.unauthenticated);
          return Error(failure);
        },
      );
    } catch (e) {
      _authStateController.add(AuthenticationState.unauthenticated);
      return Error(UnknownFailure('Login error: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // Remove token and cached user data
      await Future.wait([
        _localDataSource.removeToken(),
        _localDataSource.removeCachedUser(),
      ]);

      // Update auth state
      _authStateController.add(AuthenticationState.unauthenticated);

      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Logout error: $e'));
    }
  }

  @override
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  @override
  Future<bool> setToken(String token) async {
    return await _localDataSource.setToken(token);
  }

  @override
  Future<bool> removeToken() async {
    final removed = await _localDataSource.removeToken();
    if (removed) {
      _authStateController.add(AuthenticationState.unauthenticated);
    }
    return removed;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasToken();
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      // First try to get cached user
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Success(cachedUser.toEntity());
      }

      // If no cached user, fetch from API
      final userResult = await _remoteDataSource.getCurrentUser();

      return userResult.when(
        success: (userModel) async {
          // Cache the user data
          await _localDataSource.setCachedUser(userModel);
          return Success(userModel.toEntity());
        },
        error: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(UnknownFailure('Get current user error: $e'));
    }
  }

  @override
  Future<Result<String>> refreshToken() async {
    try {
      final refreshResult = await _remoteDataSource.refreshToken();

      return refreshResult.when(
        success: (newToken) async {
          // Store the new token
          await _localDataSource.setToken(newToken);
          return Success(newToken);
        },
        error: (failure) {
          // If refresh fails, clear stored token
          _localDataSource.removeToken();
          _authStateController.add(AuthenticationState.expired);
          return Error(failure);
        },
      );
    } catch (e) {
      return Error(UnknownFailure('Token refresh error: $e'));
    }
  }

  @override
  Future<bool> isTokenValid() async {
    try {
      // Simple check: if we have a token, assume it's valid
      // In a real app, you might want to verify with the server
      final hasToken = await _localDataSource.hasToken();

      if (!hasToken) {
        return false;
      }

      // For now, we'll assume the token is valid if it exists
      // You could implement more sophisticated validation here
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<AuthenticationState> get authStateStream =>
      _authStateController.stream;

  /// Clean up resources
  void dispose() {
    _authStateController.close();
  }
}
