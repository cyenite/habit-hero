import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialAuthRepository {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  SocialAuthRepository(this._supabase)
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

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
      if (error.toString().contains('timeout')) {
        throw 'Connection timeout. Please check your internet connection and try again.';
      }
      throw 'Failed to sign in with Google: $error';
    } finally {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }
}
