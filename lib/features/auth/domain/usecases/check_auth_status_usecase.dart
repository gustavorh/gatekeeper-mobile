import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking authentication status
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  /// Check if user is currently authenticated and return user data if available
  Future<Result<User?>> call() async {
    try {
      // First check if we have a valid token
      final isLoggedIn = await _repository.isLoggedIn();

      if (!isLoggedIn) {
        return const Success(null); // Not logged in
      }

      // Check if token is still valid
      final isTokenValid = await _repository.isTokenValid();

      if (!isTokenValid) {
        // Token expired, clear it and return not logged in
        await _repository.removeToken();
        return const Success(null);
      }

      // Token is valid, get current user
      final userResult = await _repository.getCurrentUser();

      return userResult.when(
        success: (user) => Success(user),
        error: (failure) {
          // If we can't get user data, assume session is invalid
          _repository.removeToken();
          return const Success(null);
        },
      );
    } catch (e) {
      // On any error, assume not logged in
      return const Success(null);
    }
  }

  /// Simple check if user is logged in (without full user data)
  Future<bool> isLoggedIn() async {
    return await _repository.isLoggedIn();
  }
}
