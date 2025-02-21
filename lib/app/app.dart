import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/splash/presentation/pages/splash_page.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/core/services/service_locator.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  await ServiceLocator.initialize();
  await ref.read(authStateProvider.notifier).initializeAuth();
});

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Habit Tracker',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34C759),
          primary: const Color(0xFF34C759),
          secondary: const Color(0xFF5856D6),
          tertiary: const Color(0xFF007AFF),
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
          seedColor: const Color(0xFF30D158),
          primary: const Color(0xFF30D158),
          secondary: const Color(0xFF5E5CE6),
          tertiary: const Color(0xFF0A84FF),
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
      home: const SplashPage(),
    );
  }
}
