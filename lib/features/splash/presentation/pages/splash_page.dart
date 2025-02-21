import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/splash/presentation/controllers/splash_controller.dart';
import 'package:habit_tracker/features/splash/presentation/widgets/splash_view.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  void _handleAnimationLoaded(dynamic composition) {
    _controller.duration = composition.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashController = ref.watch(splashControllerProvider);
    splashController.navigateToNextScreen(context);

    return Scaffold(
      body: SplashView(
        controller: _controller,
        fadeAnimation: _fadeAnimation,
        onAnimationLoaded: _handleAnimationLoaded,
      ),
    );
  }
}
