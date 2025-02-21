import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/presentation/pages/auth_page.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:habit_tracker/features/habits/presentation/pages/home_page.dart';

class SplashController {
  final Ref ref;

  SplashController(this.ref);

  void navigateToNextScreen(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;

      final authState = ref.read(authStateProvider);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => authState.status == AuthStatus.authenticated
              ? const HomePage()
              : const AuthPage(),
        ),
      );
    });
  }
}

final splashControllerProvider = Provider((ref) => SplashController(ref));
