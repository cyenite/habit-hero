import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
  final DateTime expiresAt;
  final bool completed;
  final DateTime? completedAt;

  Challenge({
    String? id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.expiresAt,
    this.completed = false,
    this.completedAt,
  }) : id = id ?? const Uuid().v4();

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? xpReward,
    DateTime? expiresAt,
    bool? completed,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      xpReward: xpReward ?? this.xpReward,
      expiresAt: expiresAt ?? this.expiresAt,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_code': icon.codePoint,
      'color_value': color.value.toString(),
      'xp_reward': xpReward,
      'expires_at': expiresAt.toIso8601String(),
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(int.parse(json['color_value'])),
      xpReward: json['xp_reward'],
      expiresAt: DateTime.parse(json['expires_at']),
      completed: json['completed'] ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  static List<Challenge> generateDailyChallenges() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final challenges = [
      Challenge(
        title: 'Early Bird',
        description: 'Complete a habit before 9 AM',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        xpReward: 15,
        expiresAt: endOfDay,
      ),
      Challenge(
        title: 'Doubling Down',
        description: 'Complete the same habit twice today',
        icon: Icons.repeat,
        color: Colors.purple,
        xpReward: 20,
        expiresAt: endOfDay,
      ),
      Challenge(
        title: 'Variety Pack',
        description: 'Complete 3 different types of habits today',
        icon: Icons.category,
        color: Colors.blue,
        xpReward: 25,
        expiresAt: endOfDay,
      ),
    ];

    // Return a random challenge
    challenges.shuffle();
    return [challenges.first];
  }
}
