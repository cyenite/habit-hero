import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/data/adapters/adapters.dart';

class LocalStorageRepository {
  static LocalStorageRepository? _instance;
  static bool _initialized = false;

  late Box<Habit> _habitsBox;
  late Box<Map> _syncQueueBox;

  static const String _habitsBoxName = 'habits';
  static const String _syncQueueBoxName = 'sync_queue';

  // Private constructor
  LocalStorageRepository._();

  static LocalStorageRepository get instance {
    _instance ??= LocalStorageRepository._();
    return _instance!;
  }

  static bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitFrequencyAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());

    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
    _syncQueueBox = await Hive.openBox<Map>(_syncQueueBoxName);

    _initialized = true;
  }

  Future<List<Habit>> getHabits() async {
    return _habitsBox.values.toList();
  }

  Future<void> saveHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
    await _addToSyncQueue('create', habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
    await _addToSyncQueue('update', habit);
  }

  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
    await _addToSyncQueue('delete', {'id': id});
  }

  Future<void> _addToSyncQueue(String operation, dynamic data) async {
    await _syncQueueBox.add({
      'operation': operation,
      'data': data is Habit ? data.toJson() : data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map>> getSyncQueue() async {
    return _syncQueueBox.values.toList();
  }

  Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }
}
