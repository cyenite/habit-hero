import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';

final localStorageProvider = Provider<LocalStorageRepository>((ref) {
  return LocalStorageRepository.instance;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localStorageProvider),
  );
});

final habitsProvider =
    StateNotifierProvider<HabitNotifier, AsyncValue<List<Habit>>>(
  (ref) => HabitNotifier(ref.watch(habitRepositoryProvider)),
);

final habitByIdProvider =
    FutureProvider.family<Habit?, String>((ref, id) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitById(id);
});

final habitCompletionsProvider =
    FutureProvider.family<List<HabitCompletion>, String>((ref, habitId) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getCompletionsForHabit(habitId);
});

final dailyCompletionsProvider =
    FutureProvider.family<List<HabitCompletion>, DateTime>((ref, date) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getCompletionsForDate(date);
});

final allCompletionsProvider =
    FutureProvider<List<HabitCompletion>>((ref) async {
  final habitsAsync = ref.watch(habitsProvider);

  final habits = habitsAsync.when(
    data: (data) => data,
    loading: () => <Habit>[],
    error: (_, __) => <Habit>[],
  );

  final allCompletions = <HabitCompletion>[];

  for (final habit in habits) {
    final completions = await ref
        .read(habitRepositoryProvider)
        .getCompletionsForHabit(habit.id);
    allCompletions.addAll(completions);
  }

  return allCompletions;
});

class HabitNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitRepository _repository;

  HabitNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    try {
      state = const AsyncValue.loading();
      final habits = await _repository.getHabits();
      state = AsyncValue.data(habits);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _repository.createHabit(habit);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeHabit(String habitId, {String? notes}) async {
    try {
      await _repository.completeHabit(habitId, notes: notes);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uncompleteHabit(String habitId, String completionId) async {
    try {
      await _repository.uncompleteHabit(habitId, completionId);
      await loadHabits();
    } catch (e) {
      rethrow;
    }
  }
}
