import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/stats_chart.dart';
import 'package:intl/intl.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
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
                'Statistics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                // Overview stats
                _buildOverviewStats(habitsAsync, completionsAsync, context),
                const SizedBox(height: 24),

                Text(
                  'Completion Chart',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                _buildMonthlyStats(completionsAsync, context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewStats(
      AsyncValue<List<Habit>> habitsAsync,
      AsyncValue<List<HabitCompletion>> completionsAsync,
      BuildContext context) {
    return habitsAsync.when(
      data: (habits) {
        return completionsAsync.when(
          data: (completions) {
            // Calculate total habits
            final totalHabits = habits.length;

            // Calculate total completions
            final totalCompletions = completions.length;

            // Calculate active streak
            int activeStreak = 0;
            if (habits.isNotEmpty) {
              activeStreak = habits
                  .map((habit) => habit.streak)
                  .reduce((a, b) => a > b ? a : b);
            }

            // Calculate average completions per day
            final firstCompletionDate = completions.isEmpty
                ? DateTime.now()
                : completions
                    .map((c) => c.date)
                    .reduce((a, b) => a.isBefore(b) ? a : b);

            final daysSinceFirstCompletion =
                DateTime.now().difference(firstCompletionDate).inDays;

            final avgCompletionsPerDay = daysSinceFirstCompletion <= 0
                ? 0.0
                : totalCompletions / daysSinceFirstCompletion;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatTile(
                  context,
                  'Total Habits',
                  totalHabits.toString(),
                  Icons.format_list_bulleted,
                  Colors.blue,
                ),
                _buildStatTile(
                  context,
                  'Total Completions',
                  totalCompletions.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatTile(
                  context,
                  'Current Streak',
                  '$activeStreak days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatTile(
                  context,
                  'Avg. Completions',
                  '${avgCompletionsPerDay.toStringAsFixed(1)}/day',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading completions'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading habits'),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    // Two columns if wide enough, otherwise full width
    final tileWidth = width > 600 ? (width - 40) / 2 : width - 32;

    return Container(
      width: tileWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(AsyncValue<List<HabitCompletion>> completionsAsync,
      BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return completionsAsync.when(
      data: (completions) {
        if (completions.isEmpty) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No completions recorded yet'),
            ),
          );
        }

        // Group completions by month
        final Map<String, int> completionsByMonth = {};

        for (final completion in completions) {
          final monthYear = DateFormat('MMM yyyy').format(completion.date);
          completionsByMonth[monthYear] =
              (completionsByMonth[monthYear] ?? 0) + 1;
        }

        // Sort months chronologically
        final sortedMonths = completionsByMonth.keys.toList()
          ..sort((a, b) {
            final dateA = DateFormat('MMM yyyy').parse(a);
            final dateB = DateFormat('MMM yyyy').parse(b);
            return dateB.compareTo(dateA); // Newest first
          });

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedMonths.length,
            itemBuilder: (context, index) {
              final month = sortedMonths[index];
              final count = completionsByMonth[month] ?? 0;

              return ListTile(
                title: Text(month),
                trailing: Text(
                  '$count ${count == 1 ? 'completion' : 'completions'}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading completions'),
    );
  }
}
