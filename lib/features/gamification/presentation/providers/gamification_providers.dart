import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart';
import 'package:habit_tracker/features/gamification/domain/models/challenge.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_provider.dart';

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getAchievements();
});

final unlockedAchievementsProvider =
    FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getUnlockedAchievements();
});

final dailyChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getDailyChallenges();
});

// User's current level based on total XP across all habits
final userLevelProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final habitsAsync = ref.watch(habitsProvider);

  // Handle AsyncValue directly
  final habits = habitsAsync.value ?? [];

  int totalXp = 0;
  for (final habit in habits) {
    totalXp += habit.xpPoints.toInt(); // Convert double to int if needed
  }

  int level = (totalXp / 100).floor() + 1;
  int xpForNextLevel = level * 100;
  int currentLevelXp = totalXp - ((level - 1) * 100);
  double progress = currentLevelXp / 100;

  return {
    'level': level,
    'totalXp': totalXp,
    'nextLevelXp': xpForNextLevel,
    'currentLevelXp': currentLevelXp,
    'progress': progress,
  };
});
