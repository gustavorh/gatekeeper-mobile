import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../entities/auth_credentials.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Authenticate user with credentials
  Future<Result<User>> login(AuthCredentials credentials);

  /// Log out the current user
  Future<Result<void>> logout();

  /// Get the currently stored authentication token
  Future<String?> getToken();

  /// Store authentication token
  Future<bool> setToken(String token);

  /// Remove stored authentication token
  Future<bool> removeToken();

  /// Check if user is currently logged in
  Future<bool> isLoggedIn();

  /// Get current user profile
  Future<Result<User>> getCurrentUser();

  /// Refresh authentication token if needed
  Future<Result<String>> refreshToken();

  /// Check if the stored token is still valid
  Future<bool> isTokenValid();

  /// Stream of authentication state changes
  Stream<AuthenticationState> get authStateStream;
}

/// Represents different authentication states
enum AuthenticationState {
  /// User is not authenticated
  unauthenticated,

  /// User is authenticated
  authenticated,

  /// Authentication is being checked
  checking,

  /// Authentication has expired
  expired,
}
