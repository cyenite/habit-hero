import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/features/habits/presentation/pages/edit_habit_page.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/calendar_view.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/streak_badge.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/level_indicator.dart';

class HabitDetailPage extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailPage({
    super.key,
    required this.habitId,
  });

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitByIdProvider(widget.habitId));
    final completionsAsync =
        ref.watch(habitCompletionsProvider(widget.habitId));

    return Scaffold(
      appBar: AppBar(
        title: habitAsync.when(
          data: (habit) => Text(habit?.name ?? 'Habit Detail'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          habitAsync.maybeWhen(
            data: (habit) => habit != null
                ? _buildAppBarActions(context, ref, habit)
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return const Center(
              child: Text('Habit not found'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitHeader(context, habit),
                const SizedBox(height: 24),
                _buildStatsSection(context, habit),
                const SizedBox(height: 32),
                _buildCalendarSection(
                    context, completionsAsync, widget.habitId),
                const SizedBox(height: 32),
                _buildActionSection(context, ref, habit),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context, WidgetRef ref, Habit habit) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditHabitPage(habit: habit),
              ),
            ).then((_) {
              // ignore: no_wildcard_variable_uses
              _ = ref.refresh(habitByIdProvider(widget.habitId));
            });
            break;
          case 'delete':
            _showDeleteConfirmation(context, ref, habit);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitHeader(BuildContext context, Habit habit) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            habit.icon,
            size: 32,
            color: habit.color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (habit.description != null && habit.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    habit.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit.reminderTime.format(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(habit),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Habit habit) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    StreakBadge(streak: habit.streak),
                    const SizedBox(height: 8),
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${habit.longestStreak} days',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Longest Streak',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        habit.totalCompletions.toString(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Completions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LevelIndicator(
            level: habit.level,
            xp: habit.xpPoints,
            nextLevelXp: habit.level * 50,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    BuildContext context,
    AsyncValue<List<HabitCompletion>> completionsAsync,
    String habitId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        completionsAsync.when(
          data: (completions) {
            return CalendarView(
              completions: completions,
              habitId: habitId,
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading completions: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, WidgetRef ref, Habit habit) {
    final completedToday = habit.lastCompletedDate != null &&
        _isSameDay(habit.lastCompletedDate!, DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            completedToday ? 'Completed Today' : 'Mark as Complete for Today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: completedToday
                ? null
                : () => _completeHabit(context, ref, habit),
            icon: Icon(
              completedToday ? Icons.check_circle : Icons.add_task,
              color: completedToday
                  ? Colors.green
                  : Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(completedToday ? 'Done for today' : 'Complete'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: completedToday
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: completedToday
                  ? Colors.green
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _completeHabit(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        return AlertDialog(
          title: const Text('Complete Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mark "${habit.name}" as complete for today?'),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final dialogContext = context;

                ref
                    .read(habitsProvider.notifier)
                    .completeHabit(
                      habit.id,
                      notes: notesController.text.isNotEmpty
                          ? notesController.text
                          : null,
                    )
                    .then((_) {
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Great job! "${habit.name}" completed.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // ignore: no_wildcard_variable_uses
                    _ = ref.refresh(habitByIdProvider(widget.habitId));
                  }
                });
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id).then((_) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Habit "${habit.name}" deleted'),
                  ),
                );
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(Habit habit) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        final days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        final selectedDays = <String>[];
        for (int i = 0; i < habit.selectedDays.length; i++) {
          if (habit.selectedDays[i]) {
            selectedDays.add(days[i].substring(0, 3));
          }
        }
        return selectedDays.join(', ');
      case HabitFrequency.monthly:
        return 'Monthly';
      default:
        return 'Custom';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
