import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/domain/validators/habit_validator.dart';
import 'package:uuid/uuid.dart';

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

@HiveType(typeId: 3)
class HabitCompletion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String habitId;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final String? notes;

  HabitCompletion({
    String? id,
    required this.date,
    required this.habitId,
    required this.completed,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'habit_id': habitId,
      'completed': completed,
      'notes': notes,
    };
  }

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'],
      date: DateTime.parse(json['date']),
      habitId: json['habit_id'],
      completed: json['completed'],
      notes: json['notes'],
    );
  }
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
  final List<bool> selectedDays;

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

  @HiveField(12)
  final DateTime? lastCompletedDate;

  @HiveField(13)
  final int longestStreak;

  @HiveField(14)
  final int totalCompletions;

  @HiveField(15)
  final int xpPoints;

  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(int.parse(colorValue));

  Habit({
    String? id,
    required this.name,
    this.description,
    required this.frequency,
    required this.selectedDays,
    required this.reminderTime,
    DateTime? createdAt,
    this.streak = 0,
    this.level = 1,
    this.progress = 0.0,
    IconData icon = Icons.star,
    required Color color,
    this.lastCompletedDate,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.xpPoints = 0,
  })  : id = id ?? const Uuid().v4(),
        iconData = icon.codePoint,
        colorValue = color.value.toString(),
        createdAt = createdAt ?? DateTime.now() {
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
    DateTime? lastCompletedDate,
    int? longestStreak,
    int? totalCompletions,
    int? xpPoints,
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
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      xpPoints: xpPoints ?? this.xpPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency.index,
      'selected_days': selectedDays,
      'reminder_time': '${reminderTime.hour}:${reminderTime.minute}',
      'created_at': createdAt.toIso8601String(),
      'streak': streak,
      'level': level,
      'progress': progress,
      'icon_data': iconData,
      'color_value': colorValue,
      'last_completed_date': lastCompletedDate?.toIso8601String(),
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
      'xp_points': xpPoints,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final reminderTimeParts = (json['reminder_time'] as String).split(':');
    final hour = int.parse(reminderTimeParts[0]);
    final minute = int.parse(reminderTimeParts[1]);

    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'] is int
          ? HabitFrequency.values[json['frequency']]
          : HabitFrequency.daily,
      selectedDays: (json['selected_days'] as List).cast<bool>(),
      reminderTime: TimeOfDay(hour: hour, minute: minute),
      createdAt: DateTime.parse(json['created_at']),
      streak: json['streak'] ?? 0,
      level: json['level'] ?? 1,
      progress: json['progress'] ?? 0.0,
      icon: IconData(json['icon_data'], fontFamily: 'MaterialIcons'),
      color: Color(int.parse(json['color_value'])),
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'])
          : null,
      longestStreak: json['longest_streak'] ?? 0,
      totalCompletions: json['total_completions'] ?? 0,
      xpPoints: json['xp_points'] ?? 0,
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
