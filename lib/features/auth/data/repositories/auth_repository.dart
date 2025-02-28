import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:convert';

class AuthRepository {
  final supabase.SupabaseClient _supabase;
  static const String _sessionKey = 'auth_session';

  AuthRepository(this._supabase) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStr = prefs.getString(_sessionKey);

      if (sessionStr != null) {
        await _supabase.auth.recoverSession(sessionStr);
      }
    } catch (e) {
      await _clearSession();
    }
  }

  Future<void> _persistSession(supabase.Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (response.session != null) {
      await _persistSession(response.session!);

      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
      });
    }

    return response;
  }

  Future<supabase.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      await _persistSession(response.session!);
    }

    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _clearSession();
  }

  supabase.User? get currentUser => _supabase.auth.currentUser;

  Stream<supabase.AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      // Persist session when it changes
      if (event.session != null) {
        _persistSession(event.session!);
      } else {
        _clearSession();
      }
      return event;
    });
  }

  Future<void> restoreSession() async {
    await _restoreSession();
  }

  // Add a helper method to format error messages
  String _formatAuthError(dynamic error) {
    if (error is supabase.AuthException) {
      switch (error.statusCode) {
        case '400':
          if (error.message.contains('Email not confirmed')) {
            return 'Please verify your email before signing in';
          } else if (error.message.contains('Invalid login credentials')) {
            return 'Invalid email or password';
          }
          return 'Invalid request: ${error.message}';
        case '401':
          return 'Invalid credentials';
        case '404':
          return 'User not found';
        case '422':
          if (error.message.contains('already registered')) {
            return 'Email already in use';
          }
          return 'Validation error: ${error.message}';
        case '429':
          return 'Too many requests. Please try again later';
        default:
          return error.message;
      }
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection';
    } else if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please try again';
    }

    return 'Authentication error: ${error.toString()}';
  }

  // Then modify your sign in method to use this helper
  Future<supabase.AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _formatAuthError(e);
    }
  }

  // Do the same for other auth methods
  Future<supabase.AuthResponse> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _formatAuthError(e);
    }
  }
}
