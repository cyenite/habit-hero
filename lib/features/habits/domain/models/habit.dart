import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/domain/validators/habit_validator.dart';

part 'habit.g.dart';

SupabaseClient get supabase => Supabase.instance.client;

@HiveType(typeId: 0)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
}

@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final HabitFrequency frequency;

  @HiveField(4)
  final List<bool> selectedDays; // For weekly habits

  @HiveField(5)
  final TimeOfDay reminderTime;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final int streak;

  @HiveField(8)
  final int level;

  @HiveField(9)
  final double progress;

  @HiveField(10)
  final int iconData;

  @HiveField(11)
  final String colorValue;

  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(int.parse(colorValue));

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.frequency,
    required this.selectedDays,
    required this.reminderTime,
    required this.createdAt,
    this.streak = 0,
    this.level = 1,
    this.progress = 0.0,
    IconData icon = Icons.star,
    required Color color,
  })  : iconData = icon.codePoint,
        colorValue = color.value.toString() {
    // Validate the habit data
    HabitValidator.validate(
      name: name,
      description: description,
      frequency: frequency,
      selectedDays: selectedDays,
      reminderTime: reminderTime,
    );
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitFrequency? frequency,
    List<bool>? selectedDays,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
    int? streak,
    int? level,
    double? progress,
    IconData? icon,
    Color? color,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      selectedDays: selectedDays ?? this.selectedDays,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency.index,
      'selected_days': selectedDays,
      'reminder_time': {
        'hour': reminderTime.hour,
        'minute': reminderTime.minute,
      },
      'created_at': createdAt.toIso8601String(),
      'streak': streak,
      'level': level,
      'progress': progress,
      'icon_data': iconData,
      'color_value': colorValue,
      'user_id': supabase.auth.currentUser?.id,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final colorValue = json['color_value'];
    final color = colorValue is String
        ? Color(int.parse(colorValue))
        : Color(colorValue as int);

    final progress = json['progress'];
    final progressValue =
        progress is int ? progress.toDouble() : progress as double;

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      frequency: HabitFrequency.values[json['frequency'] as int],
      selectedDays: (json['selected_days'] as List).cast<bool>(),
      reminderTime: TimeOfDay(
        hour: (json['reminder_time'] as Map)['hour'] as int,
        minute: (json['reminder_time'] as Map)['minute'] as int,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      streak: json['streak'] as int,
      level: json['level'] as int,
      progress: progressValue,
      icon: IconData(json['icon_data'] as int, fontFamily: 'MaterialIcons'),
      color: color,
    );
  }

  // Add a validation method for the UI
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Habit name cannot be empty';
    }
    if (value.trim().length < 3) {
      return 'Habit name must be at least 3 characters';
    }
    if (value.trim().length > 50) {
      return 'Habit name cannot exceed 50 characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }
}
