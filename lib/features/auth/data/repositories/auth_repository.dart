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
}
