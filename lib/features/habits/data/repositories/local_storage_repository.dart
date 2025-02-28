import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/habits/data/adapters/adapters.dart';
import 'package:habit_tracker/features/habits/data/adapters/habit_completion_adapter.dart'
    as completion_adapter;
import 'package:habit_tracker/features/gamification/data/adapters/achievement_adapter.dart';
import 'package:habit_tracker/features/gamification/data/adapters/challenge_adapter.dart';

class LocalStorageRepository {
  static LocalStorageRepository? _instance;
  static bool _initialized = false;

  late Box<Habit> _habitsBox;
  late Box<HabitCompletion> _completionsBox;
  late Box<Map> _syncQueueBox;

  static const String _habitsBoxName = 'habits';
  static const String _completionsBoxName = 'completions';
  static const String _syncQueueBoxName = 'sync_queue';

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
    Hive.registerAdapter(completion_adapter.HabitCompletionAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(ChallengeAdapter());

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
    await addToSyncQueue('create', habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
    await addToSyncQueue('update', habit);
  }

  Future<void> deleteHabit(String id) async {
    final completions = await getCompletionsForHabit(id);
    for (final completion in completions) {
      await _completionsBox.delete(completion.id);
    }

    await _habitsBox.delete(id);
    await addToSyncQueue('delete', {'id': id});
  }

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
    await addToSyncQueue('completion', completion);
  }

  Future<void> deleteCompletion(String id) async {
    await _completionsBox.delete(id);
    await addToSyncQueue('delete_completion', {'id': id});
  }

  Future<void> addToSyncQueue(String operation, dynamic data) async {
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

  Future<List<T>> getAll<T>(String boxName) async {
    final box = await Hive.openBox(boxName);
    final values = box.values.toList();
    return values.cast<T>();
  }

  Future<void> save<T>(String boxName, String id, T item) async {
    final box = await Hive.openBox(boxName);
    await box.put(id, item);
  }

  // Save habit without adding to sync queue (for syncing from remote)
  Future<void> updateHabitWithoutSync(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  // Save completion without adding to sync queue (for syncing from remote)
  Future<void> saveCompletionWithoutSync(HabitCompletion completion) async {
    await _completionsBox.put(completion.id, completion);
  }

  // Get all sync operations by type
  Future<List<Map>> getSyncOperationsByType(String operationType) async {
    return _syncQueueBox.values
        .where((operation) => operation['operation'] == operationType)
        .toList();
  }
}
