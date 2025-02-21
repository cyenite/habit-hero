import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

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
  final int colorValue;

  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

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
        colorValue = color.value;

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
      'selectedDays': selectedDays,
      'reminderTime': {
        'hour': reminderTime.hour,
        'minute': reminderTime.minute,
      },
      'createdAt': createdAt.toIso8601String(),
      'streak': streak,
      'level': level,
      'progress': progress,
      'iconData': iconData,
      'colorValue': colorValue,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      frequency: HabitFrequency.values[json['frequency'] as int],
      selectedDays: (json['selectedDays'] as List).cast<bool>(),
      reminderTime: TimeOfDay(
        hour: (json['reminderTime'] as Map)['hour'] as int,
        minute: (json['reminderTime'] as Map)['minute'] as int,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      streak: json['streak'] as int,
      level: json['level'] as int,
      progress: json['progress'] as double,
      icon: IconData(json['iconData'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
    );
  }
}
