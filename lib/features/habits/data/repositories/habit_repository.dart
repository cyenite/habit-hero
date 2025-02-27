import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

class HabitRepository {
  final SupabaseClient _supabase;
  final LocalStorageRepository _localStorage;

  HabitRepository(this._supabase, this._localStorage);

  Future<List<Habit>> getHabits() async {
    try {
      // First, get habits from local storage
      final localHabits = await _localStorage.getHabits();

      // Try to sync with remote if online
      try {
        final response = await _supabase
            .from('habits')
            .select()
            .order('created_at', ascending: false);

        final remoteHabits =
            response.map<Habit>((json) => Habit.fromJson(json)).toList();

        // Update local storage with remote data
        for (final habit in remoteHabits) {
          await _localStorage.saveHabit(habit);
        }

        return remoteHabits;
      } catch (e) {
        debugPrint('Error fetching remote habits: $e');
        // Return local habits if remote fetch fails
        return localHabits;
      }
    } catch (e) {
      debugPrint('Error fetching habits: $e');
      rethrow;
    }
  }

  Future<Habit?> getHabitById(String id) async {
    return await _localStorage.getHabitById(id);
  }

  Future<Habit> createHabit(Habit habit) async {
    try {
      // Save to local storage first
      await _localStorage.saveHabit(habit);

      // Schedule notification reminder
      await NotificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        reminderTime: habit.reminderTime,
        description: habit.description,
      );

      // Try to save to remote
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
        // Return local habit if remote save fails
        return habit;
      }
    } catch (e) {
      debugPrint('Error creating habit: $e');
      rethrow;
    }
  }

  Future<Habit> updateHabit(Habit habit) async {
    try {
      // Save to local storage first
      await _localStorage.updateHabit(habit);

      // Update notification reminder
      await NotificationService.cancelNotification(habit.id.hashCode);
      await NotificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        reminderTime: habit.reminderTime,
        description: habit.description,
      );

      // Try to update remote
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
        // Return local habit if remote update fails
        return habit;
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      // Delete from local storage first
      await _localStorage.deleteHabit(id);

      // Cancel notification reminder
      await NotificationService.cancelNotification(id.hashCode);

      // Try to delete from remote
      try {
        await _supabase.from('habits').delete().eq('id', id);
      } catch (e) {
        debugPrint('Error deleting from remote: $e');
        // Continue execution even if remote delete fails
      }
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  Future<void> completeHabit(String habitId, {String? notes}) async {
    try {
      final habit = await _localStorage.getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit not found');
      }

      final now = DateTime.now();
      final completion = HabitCompletion(
        date: now,
        habitId: habitId,
        completed: true,
        notes: notes,
      );

      // Calculate new streak and level
      int newStreak = habit.streak + 1;
      int newTotalCompletions = habit.totalCompletions + 1;
      int newLongestStreak =
          habit.longestStreak < newStreak ? newStreak : habit.longestStreak;

      // Calculate level (1 level for every 5 completions)
      int newLevel = (newTotalCompletions / 5).ceil();

      // XP points: 10 per completion + bonus for streaks
      int streakBonus = newStreak >= 7
          ? 20
          : newStreak >= 3
              ? 10
              : 0;
      int newXpPoints = habit.xpPoints + 10 + streakBonus;

      // Update habit with new progress data
      final updatedHabit = habit.copyWith(
        streak: newStreak,
        level: newLevel,
        progress: 1.0, // Mark as complete for today
        lastCompletedDate: now,
        longestStreak: newLongestStreak,
        totalCompletions: newTotalCompletions,
        xpPoints: newXpPoints,
      );

      // Save completion record
      await _localStorage.saveCompletion(completion);

      // Update habit with new stats
      await _localStorage.updateHabit(updatedHabit);

      // Try to sync with remote
      try {
        await _supabase.from('habit_completions').insert(completion.toJson());
        await _supabase
            .from('habits')
            .update(updatedHabit.toJson())
            .eq('id', habitId);
      } catch (e) {
        debugPrint('Error syncing completion with remote: $e');
        // Continue execution even if remote sync fails
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

      // Delete the completion
      await _localStorage.deleteCompletion(completionId);

      // Recalculate streak and stats
      final completions = await _localStorage.getCompletionsForHabit(habitId);
      completions.sort((a, b) => b.date.compareTo(a.date));

      int newStreak = 0;
      if (completions.isNotEmpty) {
        // Count consecutive completions up to today
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

      // Update habit with recalculated stats
      final updatedHabit = habit.copyWith(
        streak: newStreak,
        progress: completions.isEmpty ? 0.0 : 1.0,
        totalCompletions: habit.totalCompletions - 1,
        // Keep longest streak, just update current streak
      );

      await _localStorage.updateHabit(updatedHabit);

      // Try to sync with remote
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
        // Continue execution even if remote sync fails
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
}
