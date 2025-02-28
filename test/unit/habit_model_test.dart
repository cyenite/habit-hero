import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('should create a valid Habit instance', () {
      final habit = Habit(
        id: '1',
        name: 'Morning Run',
        description: 'Run for 30 minutes',
        frequency: HabitFrequency.daily,
        selectedDays: List.filled(7, true),
        reminderTime: const TimeOfDay(hour: 7, minute: 0),
        createdAt: DateTime(2023, 1, 1),
        icon: Icons.directions_run,
        color: Colors.blue,
      );

      expect(habit.id, '1');
      expect(habit.name, 'Morning Run');
      expect(habit.description, 'Run for 30 minutes');
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.reminderTime.hour, 7);
      expect(habit.reminderTime.minute, 0);
      expect(habit.createdAt, DateTime(2023, 1, 1));
      expect(habit.streak, 0); // Default value
      expect(habit.level, 1); // Default value
    });

    test('should convert Habit to and from JSON correctly', () {
      final originalHabit = Habit(
        id: '1',
        name: 'Meditation',
        description: 'Meditate for 10 minutes',
        frequency: HabitFrequency.daily,
        selectedDays: List.filled(7, true),
        reminderTime: const TimeOfDay(hour: 8, minute: 30),
        createdAt: DateTime(2023, 1, 1),
        streak: 5,
        level: 2,
        progress: 0.5,
        icon: Icons.self_improvement,
        color: Colors.purple,
      );

      final json = originalHabit.toJson();
      final recreatedHabit = Habit.fromJson(json);

      expect(recreatedHabit.id, originalHabit.id);
      expect(recreatedHabit.name, originalHabit.name);
      expect(recreatedHabit.description, originalHabit.description);
      expect(recreatedHabit.frequency, originalHabit.frequency);
      expect(recreatedHabit.reminderTime.hour, originalHabit.reminderTime.hour);
      expect(recreatedHabit.reminderTime.minute,
          originalHabit.reminderTime.minute);
      expect(recreatedHabit.streak, originalHabit.streak);
      expect(recreatedHabit.level, originalHabit.level);
      expect(recreatedHabit.progress, originalHabit.progress);
    });

    test('validateName should return null for valid name', () {
      expect(Habit.validateName('Morning Exercise'), null);
    });

    test('validateName should return error message for empty name', () {
      expect(Habit.validateName(''), isNotNull);
    });

    test('validateName should return error message for short name', () {
      expect(Habit.validateName('Ab'), isNotNull);
    });

    test('validateDescription should return null for valid description', () {
      expect(Habit.validateDescription('This is a valid description'), null);
    });

    test(
        'validateDescription should return error message for too long description',
        () {
      expect(Habit.validateDescription('A' * 501), isNotNull);
    });
  });
}
