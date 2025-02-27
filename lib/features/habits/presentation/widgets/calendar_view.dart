import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:intl/intl.dart';

class CalendarView extends ConsumerStatefulWidget {
  final List<HabitCompletion> completions;
  final String habitId;

  const CalendarView({
    super.key,
    required this.completions,
    required this.habitId,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  @override
  Widget build(BuildContext context) {
    final sortedCompletions = [...widget.completions]
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group completions by month
    final Map<String, List<HabitCompletion>> completionsByMonth = {};
    for (final completion in sortedCompletions) {
      final monthKey = DateFormat('MMMM yyyy').format(completion.date);
      if (!completionsByMonth.containsKey(monthKey)) {
        completionsByMonth[monthKey] = [];
      }
      completionsByMonth[monthKey]!.add(completion);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Calendar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        for (final monthEntry in completionsByMonth.entries)
          _buildMonthSection(context, ref, monthEntry.key, monthEntry.value),
        if (completionsByMonth.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No completions recorded yet',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    WidgetRef ref,
    String month,
    List<HabitCompletion> monthCompletions,
  ) {
    // Get the first day of the month
    final date = DateFormat('MMMM yyyy').parse(month);
    final daysInMonth = _getDaysInMonth(date.year, date.month);

    // Create a map of completions by day
    final Map<int, HabitCompletion> completionsByDay = {};
    for (final completion in monthCompletions) {
      completionsByDay[completion.date.day] = completion;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final hasCompletion = completionsByDay.containsKey(day);

            return GestureDetector(
              onTap: hasCompletion
                  ? () => _showCompletionDetails(
                        context,
                        ref,
                        completionsByDay[day]!,
                      )
                  : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: hasCompletion
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight:
                          hasCompletion ? FontWeight.bold : FontWeight.normal,
                      color: hasCompletion ? Colors.green : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showCompletionDetails(
    BuildContext context,
    WidgetRef ref,
    HabitCompletion completion,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('EEEE, MMMM d, yyyy').format(completion.date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (completion.notes != null && completion.notes!.isNotEmpty) ...[
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(completion.notes!),
              const SizedBox(height: 16),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(habitsProvider.notifier)
                  .uncompleteHabit(widget.habitId, completion.id)
                  .then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completion removed'),
                    ),
                  );
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
