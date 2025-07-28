import 'package:equatable/equatable.dart';

/// Base class for all authentication events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger login
class AuthLoginRequested extends AuthEvent {
  final String rut;
  final String password;

  const AuthLoginRequested({required this.rut, required this.password});

  @override
  List<Object?> get props => [rut, password];
}

/// Event to trigger logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event to check authentication status
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Event to clear authentication errors
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
