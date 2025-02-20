import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/features/auth/presentation/pages/auth_page.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:habit_tracker/features/habits/presentation/pages/home_page.dart';
import 'package:habit_tracker/features/splash/presentation/pages/splash_page.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  // Simulate some initialization time
  await Future.delayed(const Duration(seconds: 3));
});

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(initializationProvider);
    final authState = ref.watch(authStateProvider);
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Habit Tracker',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34C759), // Soft green as primary
          primary: const Color(0xFF34C759),
          secondary: const Color(0xFF5856D6), // Soft purple
          tertiary: const Color(0xFF007AFF), // Classic iOS blue
          surface: const Color(0xFFFFFFFF),
        ).copyWith(
          shadow: const Color(0xFF8E8E93).withOpacity(0.15),
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: const TextStyle(color: Color(0xFF1C1C1E)),
          displayMedium: const TextStyle(color: Color(0xFF1C1C1E)),
          displaySmall: const TextStyle(color: Color(0xFF1C1C1E)),
          bodyLarge: const TextStyle(color: Color(0xFF3A3A3C)),
          bodyMedium: const TextStyle(color: Color(0xFF3A3A3C)),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor:
              const Color(0xFF30D158), // Slightly brighter green for dark mode
          primary: const Color(0xFF30D158),
          secondary: const Color(0xFF5E5CE6), // Adjusted purple for dark mode
          tertiary: const Color(0xFF0A84FF), // Adjusted blue for dark mode
          surface: const Color(0xFF1C1C1E),
        ).copyWith(
          shadow: const Color(0xFF000000).withOpacity(0.2),
        ),
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: const TextStyle(color: Color(0xFFFFFFFF)),
          displayMedium: const TextStyle(color: Color(0xFFFFFFFF)),
          displaySmall: const TextStyle(color: Color(0xFFFFFFFF)),
          bodyLarge: const TextStyle(color: Color(0xFFEBEBF5)),
          bodyMedium: const TextStyle(color: Color(0xFFEBEBF5)),
        ),
      ),
      home: initialization.when(
        data: (_) => authState.status == AuthStatus.authenticated
            ? const HomePage()
            : const AuthPage(),
        loading: () => const SplashPage(),
        error: (error, stack) => const AuthPage(),
      ),
    );
  }
}
