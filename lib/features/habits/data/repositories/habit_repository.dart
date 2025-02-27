import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class HabitRepository {
  final SupabaseClient _supabase;
  final LocalStorageRepository _localStorage;

  final bool _localOnly = false;

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

      final updatedHabit = habit.copyWith(
        lastCompletedDate: DateTime.now(),
        streak: newStreak,
        longestStreak: newLongestStreak,
        totalCompletions: newTotalCompletions,
        progress: (newTotalCompletions / 30).clamp(0.0, 1.0),
      );

      await _localStorage.saveHabit(updatedHabit);

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
}
