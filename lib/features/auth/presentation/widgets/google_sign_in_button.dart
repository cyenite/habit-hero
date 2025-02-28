import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(authStateProvider.notifier).signInWithGoogle();
      },
      child: Image.asset(
        'assets/images/google-signin.png',
        height: 48,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
