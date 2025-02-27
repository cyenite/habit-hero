import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart';
import 'package:habit_tracker/features/gamification/domain/models/challenge.dart';

class HabitRepository {
  final SupabaseClient _supabase;
  final LocalStorageRepository _localStorage;

  final bool _localOnly = false;

  final _achievementsBox = 'achievements';
  final _challengesBox = 'challenges';

  HabitRepository(this._supabase, this._localStorage);

  Future<List<Habit>> getHabits() async {
    try {
      final localHabits = await _localStorage.getHabits();

      if (_localOnly) {
        return localHabits;
      }

      try {
        final response = await _supabase
            .from('habits')
            .select()
            .order('created_at', ascending: false);

        final remoteHabits =
            response.map<Habit>((json) => Habit.fromJson(json)).toList();

        for (final habit in remoteHabits) {
          await _localStorage.saveHabit(habit);
        }

        return await _localStorage.getHabits();
      } catch (e) {
        // If remote sync fails, just use local data
        debugPrint('Error fetching remote habits: $e');
        return localHabits;
      }
    } catch (e) {
      debugPrint('Error in getHabits: $e');
      rethrow;
    }
  }

  Future<Habit?> getHabitById(String id) async {
    return await _localStorage.getHabitById(id);
  }

  Future<Habit> createHabit(Habit habit) async {
    try {
      await _localStorage.saveHabit(habit);

      // Schedule notification reminder
      await NotificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        reminderTime: habit.reminderTime,
        description: habit.description,
      );

      if (_localOnly) {
        return habit;
      }

      try {
        final response = await _supabase
            .from('habits')
            .insert(habit.toJson())
            .select()
            .single();

        final remoteHabit = Habit.fromJson(response);
        return remoteHabit;
      } catch (e) {
        debugPrint('Error saving to remote: $e');
        return habit;
      }
    } catch (e) {
      debugPrint('Error creating habit: $e');
      rethrow;
    }
  }

  Future<Habit> updateHabit(Habit habit) async {
    try {
      await _localStorage.updateHabit(habit);

      await NotificationService.cancelNotification(habit.id.hashCode);
      await NotificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        reminderTime: habit.reminderTime,
        description: habit.description,
      );

      if (_localOnly) {
        return habit;
      }

      try {
        final response = await _supabase
            .from('habits')
            .update(habit.toJson())
            .eq('id', habit.id)
            .select()
            .single();

        final remoteHabit = Habit.fromJson(response);
        return remoteHabit;
      } catch (e) {
        debugPrint('Error updating remote: $e');
        return habit;
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _localStorage.deleteHabit(id);

      await NotificationService.cancelNotification(id.hashCode);

      if (_localOnly) {
        return;
      }

      try {
        await _supabase.from('habits').delete().eq('id', id);
      } catch (e) {
        debugPrint('Error deleting from remote: $e');
      }
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  Future<void> completeHabit(String habitId, {String? notes}) async {
    try {
      final habit = await getHabitById(habitId);

      if (habit == null) {
        throw Exception('Habit not found');
      }

      final completion = HabitCompletion(
        id: const Uuid().v4(),
        date: DateTime.now(),
        habitId: habitId,
        completed: true,
        notes: notes,
      );

      await _localStorage.saveCompletion(completion);

      int newStreak = habit.streak + 1;
      int newTotalCompletions = habit.totalCompletions + 1;
      int newLongestStreak =
          habit.longestStreak < newStreak ? newStreak : habit.longestStreak;

      // Calculate XP earned
      int earnedXP = 5; // Base XP for completion

      // Bonus XP for streaks
      if (newStreak >= 30) {
        earnedXP += 15;
      } else if (newStreak >= 7) {
        earnedXP += 10;
      } else if (newStreak >= 3) {
        earnedXP += 5;
      }

      int totalXP = habit.xpPoints + earnedXP;

      // Calculate level from XP (every 100 XP = 1 level)
      int newLevel = (totalXP / 100).floor() + 1;

      final updatedHabit = habit.copyWith(
        lastCompletedDate: DateTime.now(),
        streak: newStreak,
        longestStreak: newLongestStreak,
        totalCompletions: newTotalCompletions,
        progress: (newTotalCompletions / 30).clamp(0.0, 1.0),
        xpPoints: totalXP,
        level: newLevel,
      );

      await _localStorage.saveHabit(updatedHabit);

      // Check for achievements
      await _checkAndUnlockAchievements(updatedHabit);

      // Check for challenge completion
      await _checkChallengeCompletion(updatedHabit);

      if (_localOnly) {
        return;
      }

      try {
        await _supabase.from('habit_completions').insert(completion.toJson());
        await _supabase
            .from('habits')
            .update(updatedHabit.toJson())
            .eq('id', habitId);
      } catch (e) {
        debugPrint('Error syncing completion with remote: $e');
      }
    } catch (e) {
      debugPrint('Error completing habit: $e');
      rethrow;
    }
  }

  Future<void> uncompleteHabit(String habitId, String completionId) async {
    try {
      final habit = await _localStorage.getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }

      await _localStorage.deleteCompletion(completionId);

      final completions = await _localStorage.getCompletionsForHabit(habitId);
      completions.sort((a, b) => b.date.compareTo(a.date));

      int newStreak = 0;
      if (completions.isNotEmpty) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        for (int i = 0; i < completions.length; i++) {
          final completionDate = completions[i].date;
          final dateToCheck = todayDate.subtract(Duration(days: i));

          final completionDay = DateTime(
              completionDate.year, completionDate.month, completionDate.day);

          if (completionDay.isAtSameMomentAs(dateToCheck)) {
            newStreak++;
          } else {
            break;
          }
        }
      }

      final updatedHabit = habit.copyWith(
        streak: newStreak,
        progress: completions.isEmpty ? 0.0 : 1.0,
        totalCompletions: habit.totalCompletions - 1,
      );

      await _localStorage.updateHabit(updatedHabit);

      if (_localOnly) {
        return;
      }

      try {
        await _supabase
            .from('habit_completions')
            .delete()
            .eq('id', completionId);
        await _supabase
            .from('habits')
            .update(updatedHabit.toJson())
            .eq('id', habitId);
      } catch (e) {
        debugPrint('Error syncing uncompletion with remote: $e');
      }
    } catch (e) {
      debugPrint('Error uncompleting habit: $e');
      rethrow;
    }
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    try {
      return await _localStorage.getCompletionsForHabit(habitId);
    } catch (e) {
      debugPrint('Error getting completions: $e');
      rethrow;
    }
  }

  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) async {
    try {
      return await _localStorage.getCompletionsForDate(date);
    } catch (e) {
      debugPrint('Error getting completions for date: $e');
      rethrow;
    }
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final achievements =
          await _localStorage.getAll<Achievement>(_achievementsBox);

      if (achievements.isEmpty) {
        // Initialize with default achievements if none exist
        final defaults = Achievement.getDefaultAchievements();
        for (final achievement in defaults) {
          await _localStorage.save(
              _achievementsBox, achievement.id, achievement);
        }
        return defaults;
      }

      return achievements;
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      // Return default achievements as fallback
      return Achievement.getDefaultAchievements();
    }
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.unlocked).toList();
  }

  Future<List<Achievement>> _checkAndUnlockAchievements(Habit habit) async {
    final achievements = await getAchievements();
    final unlockedAchievements = <Achievement>[];

    for (final achievement in achievements) {
      if (achievement.unlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.streak:
          if (achievement.name == 'Beginner Streak' && habit.streak >= 3) {
            shouldUnlock = true;
          } else if (achievement.name == 'Habit Builder' && habit.streak >= 7) {
            shouldUnlock = true;
          } else if (achievement.name == 'Consistency Master' &&
              habit.streak >= 30) {
            shouldUnlock = true;
          }
          break;

        case AchievementType.completion:
          if (achievement.name == 'First Step' && habit.totalCompletions >= 1) {
            shouldUnlock = true;
          } else if (achievement.name == 'Habitual' &&
              habit.totalCompletions >= 50) {
            shouldUnlock = true;
          }
          break;

        case AchievementType.perfect:
          // Check for Perfect Day achievement
          if (achievement.name == 'Perfect Day') {
            final allHabits = await getHabits();
            final todayCompletions = await getTodayCompletions();

            final completedHabitIds =
                todayCompletions.map((c) => c.habitId).toSet();
            final allHabitIds = allHabits.map((h) => h.id).toSet();

            if (completedHabitIds.length == allHabitIds.length &&
                allHabitIds.isNotEmpty) {
              shouldUnlock = true;
            }
          }
          break;

        default:
          break;
      }

      if (shouldUnlock) {
        final unlocked = achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );

        await _localStorage.save(_achievementsBox, achievement.id, unlocked);
        unlockedAchievements.add(unlocked);

        // Add XP to the habit for unlocking achievement
        final updatedHabit = habit.copyWith(
          xpPoints: habit.xpPoints + achievement.xpReward,
          level: ((habit.xpPoints + achievement.xpReward) / 100).floor() + 1,
        );

        await _localStorage.saveHabit(updatedHabit);
      }
    }

    return unlockedAchievements;
  }

  Future<List<Challenge>> getDailyChallenges() async {
    try {
      final challenges = await _localStorage.getAll<Challenge>(_challengesBox);

      // Filter out expired challenges
      final currentChallenges = challenges
          .where((c) => c.expiresAt.isAfter(DateTime.now()) || c.completed)
          .toList();

      if (currentChallenges.isEmpty) {
        // Generate new daily challenges
        final newChallenges = Challenge.generateDailyChallenges();
        for (final challenge in newChallenges) {
          await _localStorage.save(_challengesBox, challenge.id, challenge);
        }
        return newChallenges;
      }

      return currentChallenges;
    } catch (e) {
      debugPrint('Error getting challenges: $e');
      return [];
    }
  }

  Future<void> _checkChallengeCompletion(Habit habit) async {
    final challenges = await getDailyChallenges();

    for (final challenge in challenges) {
      if (challenge.completed) continue;

      bool isCompleted = false;

      // Check each challenge type
      if (challenge.title == 'Early Bird') {
        final now = DateTime.now();
        if (now.hour < 9) {
          isCompleted = true;
        }
      } else if (challenge.title == 'Doubling Down') {
        final todayCompletions = await getTodayCompletions();
        final habitCompletions =
            todayCompletions.where((c) => c.habitId == habit.id).toList();
        if (habitCompletions.length >= 2) {
          isCompleted = true;
        }
      } else if (challenge.title == 'Variety Pack') {
        final todayCompletions = await getTodayCompletions();
        final uniqueHabitIds = todayCompletions.map((c) => c.habitId).toSet();
        if (uniqueHabitIds.length >= 3) {
          isCompleted = true;
        }
      }

      if (isCompleted) {
        final completedChallenge = challenge.copyWith(
          completed: true,
          completedAt: DateTime.now(),
        );

        await _localStorage.save(
            _challengesBox, challenge.id, completedChallenge);

        // Add XP to the habit for completing the challenge
        final updatedHabit = habit.copyWith(
          xpPoints: habit.xpPoints + challenge.xpReward,
          level: ((habit.xpPoints + challenge.xpReward) / 100).floor() + 1,
        );

        await _localStorage.saveHabit(updatedHabit);
      }
    }
  }

  Future<List<HabitCompletion>> getTodayCompletions() async {
    final allCompletions = await getCompletionsForDate(DateTime.now());
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return allCompletions
        .where((completion) =>
            completion.date.isAfter(startOfDay) &&
            completion.date.isBefore(endOfDay))
        .toList();
  }
}
