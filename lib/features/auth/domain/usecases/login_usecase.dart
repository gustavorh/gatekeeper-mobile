import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/auth_credentials.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with the provided credentials
  Future<Result<User>> call(AuthCredentials credentials) async {
    // Validate credentials before making the API call
    final validationResult = _validateCredentials(credentials);
    if (validationResult != null) {
      return Error(validationResult);
    }

    // Clean the RUT before sending to repository
    final cleanCredentials = credentials.withCleanRut();

    // Attempt login through repository
    final result = await _repository.login(cleanCredentials);

    return result.when(
      success: (user) async {
        // Additional business logic after successful login could go here
        // For example: analytics, user preferences setup, etc.
        return Success(user);
      },
      error: (failure) => Error(failure),
    );
  }

  /// Validate credentials according to business rules
  ValidationFailure? _validateCredentials(AuthCredentials credentials) {
    if (credentials.rut.trim().isEmpty) {
      return const ValidationFailure('El RUT es requerido');
    }

    if (credentials.password.trim().isEmpty) {
      return const ValidationFailure('La contraseña es requerida');
    }

    if (!credentials.isValidRut) {
      return const ValidationFailure('El formato del RUT no es válido');
    }

    if (!credentials.isValidPassword) {
      return const ValidationFailure(
        'La contraseña debe tener al menos 6 caracteres',
      );
    }

    return null; // No validation errors
  }
}
