import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WebAuthRepository {
  final SupabaseClient _supabase;

  WebAuthRepository(this._supabase);

  Future<AuthResponse> signInWithGoogleWeb() async {
    if (!kIsWeb) {
      throw 'This method is only available on web platforms';
    }

    try {
      // Get the current URL
      final currentUrl = Uri.base;

      // Construct the redirect URL based on the current domain
      final redirectUrl =
          '${currentUrl.scheme}://${currentUrl.host}${currentUrl.port != 80 && currentUrl.port != 443 ? ':${currentUrl.port}' : ''}';

      // Use Supabase's OAuth sign-in for web with explicit redirect
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      // Create a dummy AuthResponse since we can't get a real one on web
      // The actual session will be handled by Supabase's redirect flow
      return AuthResponse(
        session: null,
        user: null,
      );
    } catch (error) {
      throw _formatAuthError(error);
    }
  }

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
}
