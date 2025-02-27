import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/activity_grid.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/stats_chart.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habits_page.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
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
    var isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Dashboard Page
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: colorScheme.surface,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your daily overview',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                actions: [
                  IconButton.filledTonal(
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    icon: isDarkMode
                        ? const Icon(Icons.light_mode, size: 20)
                        : const Icon(Icons.dark_mode, size: 20),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Cards
                      const Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department,
                              iconColor: Colors.orange,
                              label: 'Streak',
                              value: '5 days',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.task_alt,
                              iconColor: Colors.green,
                              label: 'Completed',
                              value: '80%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Today's Progress
                      Text(
                        "Today's Progress",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      const ActivityGrid(),
                      const SizedBox(height: 24),
                      // Weekly Stats
                      Text(
                        'Weekly Overview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const StatsChart(),
                      ),
                      const SizedBox(height: 24),
                      // Upcoming Reminders
                      Text(
                        'Upcoming Reminders',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _UpcomingRemindersList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Habits Page
          const HabitsPage(),
          // Stats Page
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: colorScheme.surface,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 400,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const StatsChart(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Monthly Overview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Add monthly stats here
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Profile Page
          _ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRemindersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final habits = ref.watch(habitsProvider).value ?? [];
    final now = TimeOfDay.now();

    // Sort habits by reminder time
    final upcomingHabits = habits.where((habit) {
      final reminderTime = habit.reminderTime;
      return reminderTime.hour > now.hour ||
          (reminderTime.hour == now.hour && reminderTime.minute > now.minute);
    }).toList()
      ..sort((a, b) {
        final aTime = a.reminderTime;
        final bTime = b.reminderTime;
        return (aTime.hour * 60 + aTime.minute)
            .compareTo(bTime.hour * 60 + bTime.minute);
      });

    if (upcomingHabits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'No more reminders for today',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: upcomingHabits.take(3).map((habit) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: habit.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(habit.icon, color: habit.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Reminder at ${habit.reminderTime.format(context)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined, size: 20),
                onPressed: () {
                  // TODO: Implement reminder settings
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor: colorScheme.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'John Doe',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'john.doe@example.com',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement edit profile
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Section
                _SettingsSection(
                  title: 'Preferences',
                  items: [
                    _SettingsItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        // TODO: Implement notifications settings
                      },
                    ),
                    _SettingsItem(
                      icon: ref.watch(themeProvider) == ThemeMode.dark
                          ? Icons.dark_mode
                          : ref.watch(themeProvider) == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.brightness_auto,
                      title: 'Theme',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _ThemeDialog(),
                        );
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.language,
                      title: 'Language',
                      onTap: () {
                        // TODO: Implement language settings
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SettingsSection(
                  title: 'Data',
                  items: [
                    _SettingsItem(
                      icon: Icons.backup,
                      title: 'Backup & Restore',
                      onTap: () {
                        // TODO: Implement backup & restore
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.import_export,
                      title: 'Export Data',
                      onTap: () {
                        // TODO: Implement data export
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SettingsSection(
                  title: 'About',
                  items: [
                    _SettingsItem(
                      icon: Icons.info,
                      title: 'App Info',
                      onTap: () {
                        // TODO: Show app info
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Show privacy policy
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.map((item) {
              return ListTile(
                leading: Icon(item.icon, color: colorScheme.primary, size: 20),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _ThemeDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleDialog(
      title: const Text('Choose Theme'),
      children: [
        for (final theme in ThemeMode.values)
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
              Navigator.pop(context);
            },
            child: Text(theme.name.toUpperCase()),
          ),
      ],
    );
  }
}
