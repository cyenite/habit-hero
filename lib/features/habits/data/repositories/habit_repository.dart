import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';

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
            response.map((json) => Habit.fromJson(json)).toList();

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

  Future<Habit> createHabit(Habit habit) async {
    try {
      // Save to local storage first
      await _localStorage.saveHabit(habit);

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

  Future<void> syncWithRemote() async {
    final syncQueue = await _localStorage.getSyncQueue();

    for (final operation in syncQueue) {
      try {
        switch (operation['operation']) {
          case 'create':
            await _supabase.from('habits').insert(operation['data']);
            break;
          case 'update':
            await _supabase
                .from('habits')
                .update(operation['data'])
                .eq('id', operation['data']['id']);
            break;
          case 'delete':
            await _supabase
                .from('habits')
                .delete()
                .eq('id', operation['data']['id']);
            break;
        }
      } catch (e) {
        debugPrint('Error syncing operation: $e');
        continue;
      }
    }

    await _localStorage.clearSyncQueue();
  }

  Future<Habit> updateHabit(Habit habit) async {
    try {
      final response = await _supabase
          .from('habits')
          .update(habit.toJson())
          .eq('id', habit.id)
          .select()
          .single();

      return Habit.fromJson(response);
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _supabase.from('habits').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }
}
