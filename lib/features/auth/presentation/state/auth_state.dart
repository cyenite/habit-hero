import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SocialAuthRepository _socialAuthRepository;

  AuthNotifier(this._authRepository, this._socialAuthRepository)
      : super(AuthState()) {
    _initialize();
  }

  void _initialize() {
    final user = _authRepository.currentUser;
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authRepository.authStateChanges.listen((event) {
      if (event.session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: event.session?.user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      }
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final response = await _socialAuthRepository.signInWithGoogle();

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to sign in with Google',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> initializeAuth() async {
    await _authRepository.restoreSession();
    _initialize();
  }
}
