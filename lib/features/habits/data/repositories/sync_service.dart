import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/core/services/connectivity_service.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';

class SyncService {
  final SupabaseClient _supabase;
  final LocalStorageRepository _localStorage;
  final ConnectivityService _connectivityService;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;

  SyncService(this._supabase, this._localStorage, this._connectivityService) {
    _setupConnectivityListener();
    _setupPeriodicSync();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected) {
        syncWithServer();
      }
    });
  }

  void _setupPeriodicSync() {
    // Try to sync every 15 minutes as a backup mechanism
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        syncWithServer();
      }
    });
  }

  Future<void> syncWithServer() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      debugPrint('Starting sync with server...');

      final pendingOperations = await _localStorage.getSyncQueue();

      if (pendingOperations.isEmpty) {
        debugPrint('No pending operations to sync');
        await _pullRemoteChanges();
        return;
      }

      final sortedOperations = _sortOperationsForSync(pendingOperations);

      final failedOperations = <Map>[];

      for (final operation in sortedOperations) {
        try {
          await _processOperation(operation);
        } catch (e) {
          debugPrint('Failed to process operation: $e');
          // Keep track of failed operations to preserve them in the queue
          failedOperations.add(operation);
        }
      }

      await _localStorage.clearSyncQueue();

      // Re-add failed operations to the queue for next sync attempt
      if (failedOperations.isNotEmpty) {
        for (final operation in failedOperations) {
          await _localStorage.addToSyncQueue(
              operation['operation'], operation['data']);
        }
        debugPrint(
            '${failedOperations.length} operations will be retried later');
      }

      await _pullRemoteChanges();

      debugPrint('Sync completed successfully');
    } catch (e) {
      debugPrint('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  List<Map> _sortOperationsForSync(List<Map> operations) {
    final sortedOperations = [...operations];
    sortedOperations.sort((a, b) {
      // Priority: 1. create/update habits 2. delete habits 3. completions
      final aType = a['operation'] as String;
      final bType = b['operation'] as String;

      // Habits operations first
      if (aType == 'create' || aType == 'update') return -1;
      if (bType == 'create' || bType == 'update') return 1;

      // Then deletions
      if (aType == 'delete') return -1;
      if (bType == 'delete') return 1;

      // Then completions
      return 0;
    });

    return sortedOperations;
  }

  Future<void> _processOperation(Map operation) async {
    final String operationType = operation['operation'];
    final data = Map<String, dynamic>.from(operation['data']);

    try {
      if ((operationType == 'create' || operationType == 'update') &&
          !data.containsKey('user_id')) {
        data['user_id'] = _supabase.auth.currentUser?.id;

        if (data.containsKey('frequency') && data['frequency'] is String) {
          final frequencyStr = data['frequency'] as String;
          if (frequencyStr == 'daily') {
            data['frequency'] = 0;
          } else if (frequencyStr == 'weekly') {
            data['frequency'] = 1;
          } else if (frequencyStr == 'monthly') {
            data['frequency'] = 2;
          } else {
            data['frequency'] = 0;
          }
        }
      }

      if (operationType == 'completion' && !data.containsKey('user_id')) {
        data['user_id'] = _supabase.auth.currentUser?.id;
      }

      switch (operationType) {
        case 'create':
          final habitExists = await _checkHabitExists(data['id']);
          if (!habitExists) {
            await _supabase.from('habits').insert(data);
          }
          break;
        case 'update':
          await _supabase.from('habits').update(data).eq('id', data['id']);
          break;
        case 'delete':
          await _supabase.from('habits').delete().eq('id', data['id']);
          break;
        case 'completion':
          final habitId = data['habit_id'];
          final habitExists = await _checkHabitExists(habitId);

          if (habitExists) {
            await _supabase.from('habit_completions').insert(data);
          } else {
            final habit = await _localStorage.getHabitById(habitId);
            if (habit != null) {
              await _supabase.from('habits').insert(habit.toJson());
              await _supabase.from('habit_completions').insert(data);
            } else {
              throw "Cannot sync completion - parent habit not found";
            }
          }
          break;
        case 'delete_completion':
          await _supabase
              .from('habit_completions')
              .delete()
              .eq('id', data['id']);
          break;
        default:
          debugPrint('Unknown operation type: $operationType');
      }
    } catch (e) {
      debugPrint('Error processing operation $operationType: $e');
      rethrow;
    }
  }

  Future<bool> _checkHabitExists(String habitId) async {
    try {
      final response = await _supabase
          .from('habits')
          .select('id')
          .eq('id', habitId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if habit exists: $e');
      return false;
    }
  }

  Future<void> _pullRemoteChanges() async {
    try {
      final response = await _supabase
          .from('habits')
          .select()
          .order('updated_at', ascending: false);

      final remoteHabits = response
          .map<Habit?>((json) {
            try {
              return Habit.fromJson(json);
            } catch (e) {
              debugPrint('Error parsing habit: $e');
              return null;
            }
          })
          .whereType<Habit>()
          .toList();

      for (final habit in remoteHabits) {
        await _localStorage.updateHabitWithoutSync(habit);
      }

      final completionsResponse =
          await _supabase.from('habit_completions').select();

      final remoteCompletions = completionsResponse
          .map<HabitCompletion>((json) => HabitCompletion.fromJson(json))
          .toList();

      for (final completion in remoteCompletions) {
        await _localStorage.saveCompletionWithoutSync(completion);
      }
    } catch (e) {
      debugPrint('Error pulling remote changes: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
  }
}
