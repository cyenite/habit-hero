import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum AchievementType {
  streak, // Streak based achievements
  completion, // Total completions achievements
  consistency, // Consistency based achievements
  perfect, // Perfect day/week achievements
  special // Special achievements
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    String? id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.xpReward,
    this.unlocked = false,
    this.unlockedAt,
  }) : id = id ?? const Uuid().v4();

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    AchievementType? type,
    int? xpReward,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      xpReward: xpReward ?? this.xpReward,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': icon.codePoint,
      'color_value': color.value.toString(),
      'type': type.toString().split('.').last,
      'xp_reward': xpReward,
      'unlocked': unlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(int.parse(json['color_value'])),
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      xpReward: json['xp_reward'],
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
    );
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      // Streak achievements
      Achievement(
        name: 'Beginner Streak',
        description: 'Maintain a 3-day streak for any habit',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        type: AchievementType.streak,
        xpReward: 10,
      ),
      Achievement(
        name: 'Habit Builder',
        description: 'Maintain a 7-day streak for any habit',
        icon: Icons.local_fire_department,
        color: Colors.orange.shade700,
        type: AchievementType.streak,
        xpReward: 25,
      ),
      Achievement(
        name: 'Consistency Master',
        description: 'Maintain a 30-day streak for any habit',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        type: AchievementType.streak,
        xpReward: 100,
      ),

      // Completion achievements
      Achievement(
        name: 'First Step',
        description: 'Complete a habit for the first time',
        icon: Icons.check_circle_outline,
        color: Colors.green,
        type: AchievementType.completion,
        xpReward: 5,
      ),
      Achievement(
        name: 'Habitual',
        description: 'Complete habits 50 times in total',
        icon: Icons.check_circle,
        color: Colors.green.shade700,
        type: AchievementType.completion,
        xpReward: 50,
      ),

      // Perfect achievements
      Achievement(
        name: 'Perfect Day',
        description: 'Complete all habits in a single day',
        icon: Icons.star,
        color: Colors.amber,
        type: AchievementType.perfect,
        xpReward: 20,
      ),
      Achievement(
        name: 'Perfect Week',
        description: 'Complete all habits for 7 consecutive days',
        icon: Icons.auto_awesome,
        color: Colors.amber.shade700,
        type: AchievementType.perfect,
        xpReward: 75,
      ),
    ];
  }
}
