import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class StatsChart extends ConsumerWidget {
  const StatsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(allCompletionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return habitsAsync.when(
      data: (habits) {
        return completionsAsync.when(
          data: (completions) {
            if (habits.isEmpty) {
              return Center(
                child: Text(
                  'Add habits to see statistics',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              );
            }

            // Get the past 7 days completions
            final weeklyData = _generateWeeklyData(habits, completions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 Days',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyData.map((day) {
                          // Calculate bar height (80% of available height)
                          final maxHeight = constraints.maxHeight * 0.8;
                          final barHeight = maxHeight * day.completionRate;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Completion percentage
                              Text(
                                '${(day.completionRate * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Bar
                              Container(
                                width: (constraints.maxWidth - 70) / 7,
                                height: math.max(barHeight, 4),
                                decoration: BoxDecoration(
                                  color: day.isToday
                                      ? colorScheme.primary
                                      : colorScheme.primary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Day label
                              Text(
                                day.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: day.isToday
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: day.isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text('Error loading completions',
                style: TextStyle(color: colorScheme.error)),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child:
            Text('Error loading habits', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  List<DayData> _generateWeeklyData(
      List<Habit> habits, List<HabitCompletion> completions) {
    final today = DateTime.now();
    final result = <DayData>[];

    // Generate data for the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Filter completions for this day
      final dayCompletions = completions
          .where((c) => c.date.isAfter(dayStart) && c.date.isBefore(dayEnd))
          .toList();

      // Calculate completion rate
      double completionRate = 0;
      if (habits.isNotEmpty) {
        // Count distinct habits completed on this day
        final completedHabitIds = dayCompletions
            .map((c) => c.habitId)
            .toSet(); // Use Set to get distinct habits
        completionRate = completedHabitIds.length / habits.length;
      }

      // Format day label
      String label;
      if (i == 0) {
        label = 'Today';
      } else if (i == 1) {
        label = 'Yday';
      } else {
        label = DateFormat('EEE').format(date); // e.g. "Mon"
      }

      result.add(DayData(
        date: date,
        label: label,
        completionRate: completionRate,
        isToday: i == 0,
      ));
    }

    return result;
  }
}

class DayData {
  final DateTime date;
  final String label;
  final double completionRate;
  final bool isToday;

  DayData({
    required this.date,
    required this.label,
    required this.completionRate,
    required this.isToday,
  });
}
