import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout
  Future<Result<void>> call() async {
    // Perform logout through repository
    final result = await _repository.logout();

    return result.when(
      success: (_) async {
        // Additional cleanup logic after logout could go here
        // For example: clear cached data, analytics, etc.
        return const Success(null);
      },
      error: (failure) => Error(failure),
    );
  }
}
