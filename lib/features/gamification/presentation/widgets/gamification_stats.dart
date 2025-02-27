import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/gamification/presentation/providers/gamification_providers.dart';
import 'package:habit_tracker/features/gamification/presentation/pages/achievements_page.dart';
import 'package:habit_tracker/features/gamification/presentation/pages/challenges_page.dart';

class GamificationStats extends ConsumerWidget {
  const GamificationStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(unlockedAchievementsProvider);
    final challengesAsync = ref.watch(dailyChallengesProvider);
    final userLevelAsync = ref.watch(userLevelProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Level info
              Expanded(
                child: userLevelAsync.when(
                  data: (data) {
                    return _buildStatItem(
                      context,
                      'Level ${data['level']}',
                      '${data['totalXp']} XP',
                      Icons.stars,
                      colorScheme.primary,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildStatItem(
                    context,
                    'Level',
                    'Error',
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ),

              // Achievements info
              Expanded(
                child: achievementsAsync.when(
                  data: (achievements) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AchievementsPage(),
                          ),
                        );
                      },
                      child: _buildStatItem(
                        context,
                        'Badges',
                        '${achievements.length}',
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildStatItem(
                    context,
                    'Badges',
                    'Error',
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ),

              // Challenges info
              Expanded(
                child: challengesAsync.when(
                  data: (challenges) {
                    final pending =
                        challenges.where((c) => !c.completed).length;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChallengesPage(),
                          ),
                        );
                      },
                      child: _buildStatItem(
                        context,
                        'Challenges',
                        pending > 0 ? '$pending pending' : 'Complete',
                        Icons.flag,
                        Colors.green,
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildStatItem(
                    context,
                    'Challenges',
                    'Error',
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
