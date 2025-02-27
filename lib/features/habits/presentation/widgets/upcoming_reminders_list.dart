import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';

class UpcomingRemindersList extends ConsumerWidget {
  const UpcomingRemindersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No upcoming reminders'),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.length > 3 ? 3 : habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
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
                  // Navigate to habit details
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
