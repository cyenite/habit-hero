import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/features/habits/presentation/pages/dashboard_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habits_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/profile_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/stats_page.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    final navigationDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.repeat_outlined),
        selectedIcon: Icon(Icons.repeat),
        label: 'Habits',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: 'Stats',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    if (isLargeScreen) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Row(
          children: [
            // Navigation sidebar for web
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App logo
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bolt,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Habit Hero',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Navigation items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 16),
                        ...List.generate(navigationDestinations.length,
                            (index) {
                          final isSelected = _selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        isSelected
                                            ? navigationDestinations[index]
                                                .selectedIcon!
                                            : navigationDestinations[index]
                                                .icon,
                                        const SizedBox(width: 16),
                                        Text(
                                          navigationDestinations[index].label,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Bottom section
                  InkWell(
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'Light Mode'
                                : 'Dark Mode',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  DashboardPage(),
                  HabitsPage(),
                  StatsPage(),
                  ProfilePage(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            DashboardPage(),
            HabitsPage(),
            StatsPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          destinations: navigationDestinations,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      );
    }
  }
}
