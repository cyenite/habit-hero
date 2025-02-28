import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/domain/validators/habit_validator.dart';

void main() {
  group('HabitValidator Tests', () {
    test('validate should pass for valid habit data', () {
      // Should not throw exception
      expect(
          () => HabitValidator.validate(
                name: 'Morning Exercise',
                description: 'Do 20 minutes of stretching',
                frequency: HabitFrequency.daily,
                selectedDays: List.filled(7, true),
                reminderTime: const TimeOfDay(hour: 8, minute: 0),
              ),
          returnsNormally);
    });

    test('validate should throw error for empty name', () {
      expect(
          () => HabitValidator.validate(
                name: '',
                frequency: HabitFrequency.daily,
                selectedDays: List.filled(7, true),
                reminderTime: const TimeOfDay(hour: 8, minute: 0),
              ),
          throwsA(isA<HabitValidationError>()));
    });

    test('validate should throw error for short name', () {
      expect(
          () => HabitValidator.validate(
                name: 'Ab',
                frequency: HabitFrequency.daily,
                selectedDays: List.filled(7, true),
                reminderTime: const TimeOfDay(hour: 8, minute: 0),
              ),
          throwsA(isA<HabitValidationError>()));
    });

    test('validate should throw error for too long description', () {
      final longDescription = 'A' * 501; // 501 characters
      expect(
          () => HabitValidator.validate(
                name: 'Morning Exercise',
                description: longDescription,
                frequency: HabitFrequency.daily,
                selectedDays: List.filled(7, true),
                reminderTime: const TimeOfDay(hour: 8, minute: 0),
              ),
          throwsA(isA<HabitValidationError>()));
    });

    test('validate should throw error for weekly habit with no days selected',
        () {
      expect(
          () => HabitValidator.validate(
                name: 'Morning Exercise',
                frequency: HabitFrequency.weekly,
                selectedDays: List.filled(7, false), // No days selected
                reminderTime: const TimeOfDay(hour: 8, minute: 0),
              ),
          throwsA(isA<HabitValidationError>()));
    });

    test('validate should throw error for invalid reminder time', () {
      expect(
          () => HabitValidator.validate(
                name: 'Morning Exercise',
                frequency: HabitFrequency.daily,
                selectedDays: List.filled(7, true),
                reminderTime:
                    const TimeOfDay(hour: 25, minute: 0), // Invalid hour
              ),
          throwsA(isA<HabitValidationError>()));
    });
  });
}
