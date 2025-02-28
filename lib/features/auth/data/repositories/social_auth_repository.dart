import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/auth/data/repositories/web_auth_repository.dart';

class SocialAuthRepository {
  final SupabaseClient _supabase;
  late WebAuthRepository _webAuthRepository;

  SocialAuthRepository(this._supabase) {
    if (kIsWeb) {
      _webAuthRepository = WebAuthRepository(_supabase);
    }
  }

  // Helper method to format error messages
  String _formatAuthError(dynamic error) {
    if (error is AuthException) {
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
    } else if (error.toString().contains('redirect_uri_mismatch')) {
      return 'Authentication error: Redirect URI mismatch. Please contact the developer.';
    }

    return 'Authentication error: ${error.toString()}';
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        return await _webAuthRepository.signInWithGoogleWeb();
      }

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      return AuthResponse(
        session: null,
        user: null,
      );
    } catch (error) {
      throw _formatAuthError(error);
    }
  }
}
