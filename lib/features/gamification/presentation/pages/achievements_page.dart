import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart';
import 'package:habit_tracker/features/gamification/presentation/providers/gamification_providers.dart';
import 'package:habit_tracker/features/gamification/presentation/widgets/achievement_badge.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          // Sort achievements - unlocked first, then by type
          final sortedAchievements = List<Achievement>.from(achievements)
            ..sort((a, b) {
              if (a.unlocked && !b.unlocked) return -1;
              if (!a.unlocked && b.unlocked) return 1;
              return a.type.index.compareTo(b.type.index);
            });

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Achievements',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete habits and unlock badges to earn XP',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAchievementStats(achievements),
                      const SizedBox(height: 32),
                      ..._buildAchievementCategories(
                          sortedAchievements, context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading achievements: $error'),
        ),
      ),
    );
  }

  Widget _buildAchievementStats(List<Achievement> achievements) {
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final totalCount = achievements.length;
    final progress = unlockedCount / totalCount;

    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$unlockedCount / $totalCount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildAchievementCategories(
      List<Achievement> achievements, BuildContext context) {
    final categories = {
      AchievementType.streak: 'Streak Achievements',
      AchievementType.completion: 'Completion Achievements',
      AchievementType.perfect: 'Perfect Achievements',
      AchievementType.consistency: 'Consistency Achievements',
      AchievementType.special: 'Special Achievements',
    };

    final widgets = <Widget>[];

    // Group achievements by type
    final groupedAchievements = <AchievementType, List<Achievement>>{};
    for (final achievement in achievements) {
      if (!groupedAchievements.containsKey(achievement.type)) {
        groupedAchievements[achievement.type] = [];
      }
      groupedAchievements[achievement.type]!.add(achievement);
    }

    groupedAchievements.forEach((type, typeAchievements) {
      if (typeAchievements.isEmpty) return;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categories[type] ?? 'Other Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: typeAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = typeAchievements[index];
                  return AchievementBadge(
                    achievement: achievement,
                    showDetails: true,
                    onTap: () => _showAchievementDetails(context, achievement),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(achievement.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                achievement.icon,
                size: 48,
                color: achievement.unlocked ? achievement.color : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Reward: ${achievement.xpReward} XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achievement.unlocked ? Colors.amber : Colors.grey,
                ),
              ),
              if (achievement.unlocked && achievement.unlockedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Unlocked on: ${_formatDate(achievement.unlockedAt!)}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
