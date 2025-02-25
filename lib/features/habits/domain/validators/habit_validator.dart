import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';

class HabitValidationError implements Exception {
  final String message;
  HabitValidationError(this.message);

  @override
  String toString() => message;
}

class HabitValidator {
  static void validate({
    required String name,
    String? description,
    required HabitFrequency frequency,
    required List<bool> selectedDays,
    required TimeOfDay reminderTime,
  }) {
    if (name.trim().isEmpty) {
      throw HabitValidationError('Habit name cannot be empty');
    }

    if (name.trim().length < 3) {
      throw HabitValidationError('Habit name must be at least 3 characters');
    }

    if (name.trim().length > 50) {
      throw HabitValidationError('Habit name cannot exceed 50 characters');
    }

    if (description != null && description.length > 500) {
      throw HabitValidationError('Description cannot exceed 500 characters');
    }

    if (frequency == HabitFrequency.weekly && !selectedDays.contains(true)) {
      throw HabitValidationError(
          'Please select at least one day for weekly habits');
    }

    if (reminderTime.hour < 0 ||
        reminderTime.hour > 23 ||
        reminderTime.minute < 0 ||
        reminderTime.minute > 59) {
      throw HabitValidationError('Invalid reminder time');
    }
  }
}
