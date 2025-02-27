import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/data/adapters/adapters.dart';
import 'package:habit_tracker/features/habits/data/adapters/habit_completion_adapter.dart';

class LocalStorageRepository {
  static LocalStorageRepository? _instance;
  static bool _initialized = false;

  late Box<Habit> _habitsBox;
  late Box<HabitCompletion> _completionsBox;
  late Box<Map> _syncQueueBox;

  static const String _habitsBoxName = 'habits';
  static const String _completionsBoxName = 'completions';
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
    Hive.registerAdapter(HabitCompletionAdapter());

    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
    _completionsBox = await Hive.openBox<HabitCompletion>(_completionsBoxName);
    _syncQueueBox = await Hive.openBox<Map>(_syncQueueBoxName);

    _initialized = true;
  }

  Future<List<Habit>> getHabits() async {
    return _habitsBox.values.toList();
  }

  Future<Habit?> getHabitById(String id) async {
    return _habitsBox.get(id);
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
    // Delete all completions for this habit
    final completions = await getCompletionsForHabit(id);
    for (final completion in completions) {
      await _completionsBox.delete(completion.id);
    }

    await _habitsBox.delete(id);
    await _addToSyncQueue('delete', {'id': id});
  }

  // Habit Completion methods
  Future<List<HabitCompletion>> getAllCompletions() async {
    return _completionsBox.values.toList();
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    return _completionsBox.values
        .where((completion) => completion.habitId == habitId)
        .toList();
  }

  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _completionsBox.values
        .where((completion) =>
            completion.date.isAfter(startOfDay) &&
            completion.date.isBefore(endOfDay))
        .toList();
  }

  Future<void> saveCompletion(HabitCompletion completion) async {
    await _completionsBox.put(completion.id, completion);
    await _addToSyncQueue('completion', completion);
  }

  Future<void> deleteCompletion(String id) async {
    await _completionsBox.delete(id);
    await _addToSyncQueue('delete_completion', {'id': id});
  }

  Future<void> _addToSyncQueue(String operation, dynamic data) async {
    await _syncQueueBox.add({
      'operation': operation,
      'data': data is Habit || data is HabitCompletion ? data.toJson() : data,
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
