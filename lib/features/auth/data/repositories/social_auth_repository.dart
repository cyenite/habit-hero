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
      // Start the Google sign-in flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in cancelled';

      // Get auth details from request
      final googleAuth = await googleUser.authentication;

      // Create Google OAuth credential
      final idToken = googleAuth.idToken;
      if (idToken == null) throw 'No ID token found';

      // Sign in to Supabase with Google OAuth credential
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
    } catch (error) {
      throw 'Failed to sign in with Google: $error';
    }
  }
}
