import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';

// Helper to wrap widgets with ProviderScope for testing
Widget testableWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

// Create sample habits for testing
List<Habit> createSampleHabits() {
  return [
    Habit(
      id: '1',
      name: 'Morning Run',
      description: 'Run for 30 minutes',
      frequency: HabitFrequency.daily,
      selectedDays: List.filled(7, true),
      reminderTime: const TimeOfDay(hour: 7, minute: 0),
      createdAt: DateTime(2023, 1, 1),
      streak: 5,
      level: 2,
      progress: 0.5,
      icon: Icons.directions_run,
      color: Colors.blue,
    ),
    Habit(
      id: '2',
      name: 'Read a Book',
      description: 'Read for 20 minutes',
      frequency: HabitFrequency.weekly,
      selectedDays: [true, false, true, false, true, false, false],
      reminderTime: const TimeOfDay(hour: 20, minute: 0),
      createdAt: DateTime(2023, 1, 2),
      streak: 3,
      level: 1,
      progress: 0.2,
      icon: Icons.book,
      color: Colors.green,
    ),
  ];
}
