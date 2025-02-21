import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> fadeAnimation;
  final void Function(dynamic) onAnimationLoaded;

  const SplashView({
    super.key,
    required this.controller,
    required this.fadeAnimation,
    required this.onAnimationLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/habits.json',
                    controller: controller,
                    onLoaded: onAnimationLoaded,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Habit Hero',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transform your life, one habit at a time',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
