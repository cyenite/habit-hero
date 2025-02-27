import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/features/auth/presentation/pages/auth_page.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/gamification/presentation/widgets/gamification_stats.dart';
import 'package:habit_tracker/features/gamification/presentation/widgets/level_progress.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/settings_section.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/settings_item.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/theme_dialog.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final userAsync = ref.watch(userMetadataProvider);
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
                _buildProfileCard(context, colorScheme, userAsync),
                const SizedBox(height: 24),
                const LevelProgress(),
                const SizedBox(height: 24),
                const GamificationStats(),
                const SizedBox(height: 24),
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
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'About',
              items: [
                SettingsItem(
                  icon: Icons.info,
                  title: 'App Info',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('App Info'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Habit Tracker',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Version 1.0.0',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Developed by Ron for the Solutech Interview',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {}, child: const Text('OK')),
                          ],
                        );
                      },
                    );
                  },
                ),
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('Privacy Policy'),
                          content: Text('Privacy Policy'),
                        );
                      },
                    );
                  },
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
