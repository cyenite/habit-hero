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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createHabit(Habit habit) async {
    try {
      final newHabit = await _repository.createHabit(habit);
      state.whenData((habits) {
        state = AsyncValue.data([newHabit, ...habits]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final updatedHabit = await _repository.updateHabit(habit);
      state.whenData((habits) {
        state = AsyncValue.data(
          habits.map((h) => h.id == habit.id ? updatedHabit : h).toList(),
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
      state.whenData((habits) {
        state = AsyncValue.data(habits.where((h) => h.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
