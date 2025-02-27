import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/features/auth/presentation/pages/auth_page.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/settings_section.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/settings_item.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/theme_dialog.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final userAsync = ref.watch(userMetadataProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(allCompletionsProvider);

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
                'Your account & settings',
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
                _buildProfileCard(context, colorScheme, userAsync),
                const SizedBox(height: 24),

                // Stats Summary
                _buildStatsSummary(
                    context, colorScheme, habitsAsync, completionsAsync),
                const SizedBox(height: 24),

                // Settings Sections
                _buildSettingsSections(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ColorScheme colorScheme,
    AsyncValue<Map<String, dynamic>?> userAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: userAsync.when(
        data: (userData) {
          final name = userData?['name'] ?? 'User';
          final email = userData?['email'] ?? 'No email available';
          final avatarUrl = userData?['avatar_url'];

          return Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton.filledTonal(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO(Ron): Implement edit profile
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading profile: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(
    BuildContext context,
    ColorScheme colorScheme,
    AsyncValue<List<Habit>> habitsAsync,
    AsyncValue<List<HabitCompletion>> completionsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          habitsAsync.when(
            data: (habits) {
              return completionsAsync.when(
                data: (completions) {
                  final totalHabits = habits.length;
                  final totalCompletions = completions.length;

                  // Calculate streak
                  int currentStreak = 0;
                  if (habits.isNotEmpty) {
                    currentStreak = habits
                        .map((habit) => habit.streak)
                        .reduce((a, b) => a > b ? a : b);
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        '$totalHabits',
                        'Total Habits',
                        Icons.list_alt,
                      ),
                      _buildStatItem(
                        context,
                        '$totalCompletions',
                        'Completions',
                        Icons.check_circle_outline,
                      ),
                      _buildStatItem(
                        context,
                        '$currentStreak',
                        'Current Streak',
                        Icons.local_fire_department,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading stats'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading habits'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSettingsSections(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final currentTheme =
            ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: 'General',
              items: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // TODO(Ron): Implement notifications settings
                  },
                ),
                SettingsItem(
                  icon: currentTheme == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  title: 'Theme',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ThemeDialog(),
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'Data',
              items: [
                SettingsItem(
                  icon: Icons.backup,
                  title: 'Backup & Restore',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.import_export,
                  title: 'Export Data',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'About',
              items: [
                SettingsItem(
                  icon: Icons.info,
                  title: 'App Info',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'Account',
              items: [
                SettingsItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () async {
                    final client = ref.read(supabaseClientProvider);
                    await client.auth.signOut();

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthPage(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
