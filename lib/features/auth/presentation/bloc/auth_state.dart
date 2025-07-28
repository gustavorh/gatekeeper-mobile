import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Represents the different authentication status states
enum AuthStatus {
  /// Initial state when the app starts
  initial,

  /// Authentication is being checked or login is in progress
  loading,

  /// User is successfully authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// An error occurred during authentication
  error,
}

/// Authentication state class
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Factory constructor for initial state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Factory constructor for loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Factory constructor for authenticated state
  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Factory constructor for unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Factory constructor for error state
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  /// Create a copy of the current state with updated values
  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clear error message and return to previous state
  AuthState clearError() {
    return copyWith(
      errorMessage: null,
      status: user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Check if authentication is in progress
  bool get isLoading => status == AuthStatus.loading;

  /// Check if there's an error
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  @override
  List<Object?> get props => [status, user, errorMessage];

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, error: $errorMessage)';
}
