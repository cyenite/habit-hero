import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/theme_provider.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/activity_grid.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/stat_card.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/stats_chart.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeProvider);
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
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
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              icon: themeMode == ThemeMode.dark
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
                _buildStatsCards(habitsAsync, completionsAsync),
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
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                _buildUpcomingReminders(context, habitsAsync),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(AsyncValue<List<Habit>> habitsAsync,
      AsyncValue<List<HabitCompletion>> completionsAsync) {
    return habitsAsync.when(
      data: (habits) {
        // Calculate longest streak
        int longestStreak = 0;
        if (habits.isNotEmpty) {
          longestStreak = habits
              .map((habit) => habit.longestStreak)
              .reduce((a, b) => a > b ? a : b);
        }

        // Calculate completion rate
        return completionsAsync.when(
          data: (completions) {
            // Get today's completions
            final today = DateTime.now();
            final startOfDay = DateTime(today.year, today.month, today.day);
            final endOfDay = startOfDay.add(const Duration(days: 1));

            final todaysCompletions = completions
                .where((completion) =>
                    completion.date.isAfter(startOfDay) &&
                    completion.date.isBefore(endOfDay))
                .length;

            // Calculate completion rate
            final completionRate = habits.isEmpty
                ? 0.0
                : (todaysCompletions / habits.length * 100).round();

            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    label: 'Longest Streak',
                    value:
                        '$longestStreak ${longestStreak == 1 ? 'day' : 'days'}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.task_alt,
                    iconColor: Colors.green,
                    label: 'Today\'s Completion',
                    value: '$completionRate%',
                  ),
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

  Widget _buildUpcomingReminders(
      BuildContext context, AsyncValue<List<Habit>> habitsAsync) {
    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No habits added yet'),
            ),
          );
        }

        // Sort habits by reminder time
        final sortedHabits = [...habits]..sort((a, b) =>
            a.reminderTime.hour * 60 +
            a.reminderTime.minute -
            (b.reminderTime.hour * 60 + b.reminderTime.minute));

        // Take first 3 habits
        final displayHabits = sortedHabits.take(3).toList();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayHabits.length,
            itemBuilder: (context, index) {
              final habit = displayHabits[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 20),
                ),
                title: Text(habit.name),
                subtitle: Text(
                  '${habit.reminderTime.hour}:${habit.reminderTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailPage(habitId: habit.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading habits'),
    );
  }
}
