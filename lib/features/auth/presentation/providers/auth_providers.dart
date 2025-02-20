import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/presentation/state/auth_state.dart'
    as auth;
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart';

final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final socialAuthRepositoryProvider = Provider<SocialAuthRepository>((ref) {
  return SocialAuthRepository(ref.watch(supabaseClientProvider));
});

final authStateProvider =
    StateNotifierProvider<auth.AuthNotifier, auth.AuthState>((ref) {
  return auth.AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(socialAuthRepositoryProvider),
  );
});
