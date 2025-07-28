import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_credentials.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(AuthState.initial()) {
    // Register event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthErrorCleared>(_onErrorCleared);

    // Check authentication status on startup
    add(const AuthStatusChecked());
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final credentials = AuthCredentials(
        rut: event.rut,
        password: event.password,
      );

      final result = await _loginUseCase(credentials);

      result.when(
        success: (user) {
          emit(AuthState.authenticated(user));
        },
        error: (failure) {
          emit(AuthState.error(failure.message));
        },
      );
    } catch (e) {
      emit(AuthState.error('Error inesperado durante el login: $e'));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final result = await _logoutUseCase();

      result.when(
        success: (_) {
          emit(AuthState.unauthenticated());
        },
        error: (failure) {
          // Even if logout fails, we should clear the local state
          emit(AuthState.unauthenticated());
        },
      );
    } catch (e) {
      // On any error, clear the authentication state
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle authentication status check
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final result = await _checkAuthStatusUseCase();

      result.when(
        success: (user) {
          if (user != null) {
            emit(AuthState.authenticated(user));
          } else {
            emit(AuthState.unauthenticated());
          }
        },
        error: (failure) {
          emit(AuthState.unauthenticated());
        },
      );
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle error clearing
  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.clearError());
  }

  /// Get the current user if authenticated
  get currentUser => state.user;

  /// Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;

  /// Check if loading
  bool get isLoading => state.isLoading;
}
