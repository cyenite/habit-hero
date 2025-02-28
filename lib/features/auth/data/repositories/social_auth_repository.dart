import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialAuthRepository {
  final SupabaseClient _supabase;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '474994024182-ka6kh4nprabrla21eim94stutag2740a.apps.googleusercontent.com'
        : '474994024182-b93fjlrfp8eh34j6b6tgq94kqu004k6l.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  SocialAuthRepository(this._supabase);

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
    }

    return 'Authentication error: ${error.toString()}';
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in cancelled';

      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) throw 'No ID token found';

      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          return await _supabase.auth
              .signInWithIdToken(
                provider: OAuthProvider.google,
                idToken: idToken,
                accessToken: googleAuth.accessToken,
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw 'Connection timeout',
              );
        } catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            throw 'Failed to connect to authentication service after $maxRetries attempts. Please check your internet connection and try again.';
          }
          await Future.delayed(Duration(seconds: retryCount));
        }
      }

      throw 'Unexpected error during authentication';
    } catch (error) {
      throw _formatAuthError(error);
    } finally {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }
}
