import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/auth/data/repositories/web_auth_repository.dart';

class SocialAuthRepository {
  final SupabaseClient _supabase;
  late WebAuthRepository _webAuthRepository;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '474994024182-gv7242p2k9sg87fn57cgfte3u8envgfl.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile'],
  );

  SocialAuthRepository(this._supabase) {
    if (kIsWeb) {
      _webAuthRepository = WebAuthRepository(_supabase);
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

    if (error is Exception) {
      final errorString = error.toString();

      // Handle Google Sign-In specific errors
      if (errorString.contains('ApiException: 10')) {
        return 'Google Sign-In configuration error. Please check your app\'s Google Cloud Console setup.';
      } else if (errorString.contains('sign_in_failed')) {
        return 'Google Sign-In failed. Please try again or use another sign-in method.';
      } else if (errorString.contains('network_error')) {
        return 'Network error. Please check your connection and try again.';
      } else if (errorString.contains('canceled')) {
        return 'Sign-in was canceled.';
      }
    }

    return 'Authentication error: ${error.toString()}';
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        return await _webAuthRepository.signInWithGoogleWeb();
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in cancelled';

      log('Google Sign-In successful for: ${googleUser.email}',
          name: 'SocialAuthRepository');

      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        log('ID token is null. This might be due to Google Sign-In configuration issues.',
            name: 'SocialAuthRepository');
        throw 'No ID token found. Please try again or contact support.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error) {
      throw _formatAuthError(error);
    } finally {
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
    }
  }
}
