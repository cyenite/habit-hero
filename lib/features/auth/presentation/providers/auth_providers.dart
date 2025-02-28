import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:habit_tracker/features/auth/presentation/state/auth_state.dart'
    as auth;
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

final currentUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((state) => state.session?.user);
});

final userMetadataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) {
    return null;
  }

  final client = ref.watch(supabaseClientProvider);

  try {
    final response =
        await client.from('profiles').select().eq('id', user.id).single();

    return response;
  } catch (e) {
    // Return default metadata if the profile doesn't exist yet.
    return {
      'id': user.id,
      'name':
          user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'User',
      'email': user.email,
      'avatar_url': user.userMetadata?['avatar_url'],
    };
  }
});
