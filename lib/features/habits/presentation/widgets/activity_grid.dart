import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/activity_card.dart';

class ActivityGrid extends ConsumerWidget {
  const ActivityGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(allCompletionsProvider);

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Container(
            height: 200,
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
                .toList();

            // Calculate daily completion rate
            final dailyCompletionRate = habits.length > 0
                ? todaysCompletions.length / habits.length
                : 0.0;

            // Get habit categories based on icons
            final categories = _groupHabitsByCategory(habits, completions);

            // Create activity cards for each category
            final cards = <Widget>[];

            // First add the overall completion card
            cards.add(
              ActivityCard(
                title: 'Daily Tasks',
                value: '${todaysCompletions.length}/${habits.length}',
                unit: 'completed',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF34C759), // Green
                progress: dailyCompletionRate,
              ),
            );

            // Add cards for top categories (up to 3 more cards)
            categories.entries.take(3).forEach((entry) {
              final category = entry.key;
              final categoryHabits = entry.value;

              // Calculate completion rate for this category
              final categoryCompletions = todaysCompletions
                  .where((completion) =>
                      categoryHabits.any((h) => h.id == completion.habitId))
                  .length;

              final progress = categoryHabits.length > 0
                  ? categoryCompletions / categoryHabits.length
                  : 0.0;

              cards.add(
                ActivityCard(
                  title: category.title,
                  value: '$categoryCompletions/${categoryHabits.length}',
                  unit: 'completed',
                  icon: category.icon,
                  color: category.color,
                  progress: progress,
                  showBarChart:
                      cards.length % 2 == 1, // Alternate between showing chart
                ),
              );
            });

            // Ensure we have at least 4 cards for a balanced grid
            while (cards.length < 4) {
              cards.add(
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddHabitPage(),
                      ),
                    );
                  },
                  child: const ActivityCard(
                    title: 'New Habit',
                    value: 'Add',
                    unit: 'new habits',
                    icon: Icons.add_circle_outline,
                    color: Colors.grey,
                    progress: 0.0,
                  ),
                ),
              );
            }

            return GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: cards,
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

  Map<HabitCategory, List<Habit>> _groupHabitsByCategory(
      List<Habit> habits, List<HabitCompletion> completions) {
    final categories = <HabitCategory, List<Habit>>{};

    // Create category groups
    for (final habit in habits) {
      // Determine category based on icon
      final category = _getCategoryForHabit(habit);

      if (!categories.containsKey(category)) {
        categories[category] = [];
      }

      categories[category]!.add(habit);
    }

    // Sort categories by number of habits (descending)
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Map.fromEntries(sortedEntries);
  }

  HabitCategory _getCategoryForHabit(Habit habit) {
    // Define common categories
    if (habit.icon == Icons.directions_run ||
        habit.icon == Icons.fitness_center ||
        habit.icon == Icons.self_improvement) {
      return HabitCategory('Fitness', Icons.fitness_center, Colors.orange);
    }

    if (habit.icon == Icons.book ||
        habit.icon == Icons.menu_book ||
        habit.icon == Icons.text_snippet) {
      return HabitCategory('Reading', Icons.book, Colors.blue);
    }

    if (habit.icon == Icons.water_drop || habit.icon == Icons.local_drink) {
      return HabitCategory('Health', Icons.favorite, Colors.pink);
    }

    if (habit.icon == Icons.restaurant || habit.icon == Icons.food_bank) {
      return HabitCategory('Nutrition', Icons.restaurant, Colors.green);
    }

    if (habit.icon == Icons.computer ||
        habit.icon == Icons.work ||
        habit.icon == Icons.school) {
      return HabitCategory('Productivity', Icons.computer, Colors.purple);
    }

    // Default category
    return HabitCategory('Other', Icons.star, habit.color);
  }
}

class HabitCategory {
  final String title;
  final IconData icon;
  final Color color;

  const HabitCategory(this.title, this.icon, this.color);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is HabitCategory && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}
