import 'package:hive/hive.dart';
import 'package:habit_tracker/features/habits/domain/models/habit.dart';

class HabitCompletionAdapter extends TypeAdapter<HabitCompletion> {
  @override
  final int typeId = 3;

  @override
  HabitCompletion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return HabitCompletion(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      habitId: fields[2] as String,
      completed: fields[3] as bool,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitCompletion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.habitId)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
