import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/data/repositories/social_auth_repository.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';

final socialAuthRepositoryProvider = Provider<SocialAuthRepository>((ref) {
  return SocialAuthRepository(ref.watch(supabaseClientProvider));
});
