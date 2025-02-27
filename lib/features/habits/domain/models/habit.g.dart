// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      id: fields[0] as String?,
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

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      frequency: fields[3] as HabitFrequency,
      selectedDays: (fields[4] as List).cast<bool>(),
      reminderTime: fields[5] as TimeOfDay,
      createdAt: fields[6] as DateTime?,
      streak: fields[7] != null ? fields[7] as int : 0,
      level: fields[8] != null ? fields[8] as int : 1,
      progress: fields[9] != null ? fields[9] as double : 0.0,
      color: fields[11] != null
          ? Color(int.parse(fields[11].toString()))
          : Colors.blue,
      lastCompletedDate: fields[12] as DateTime?,
      longestStreak: fields[13] != null ? fields[13] as int : 0,
      totalCompletions: fields[14] != null ? fields[14] as int : 0,
      xpPoints: fields[15] != null ? fields[15] as int : 0,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.selectedDays)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.streak)
      ..writeByte(8)
      ..write(obj.level)
      ..writeByte(9)
      ..write(obj.progress)
      ..writeByte(10)
      ..write(obj.iconData)
      ..writeByte(11)
      ..write(obj.colorValue)
      ..writeByte(12)
      ..write(obj.lastCompletedDate)
      ..writeByte(13)
      ..write(obj.longestStreak)
      ..writeByte(14)
      ..write(obj.totalCompletions)
      ..writeByte(15)
      ..write(obj.xpPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final int typeId = 0;

  @override
  HabitFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequency.daily;
      case 1:
        return HabitFrequency.weekly;
      case 2:
        return HabitFrequency.monthly;
      default:
        return HabitFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    switch (obj) {
      case HabitFrequency.daily:
        writer.writeByte(0);
        break;
      case HabitFrequency.weekly:
        writer.writeByte(1);
        break;
      case HabitFrequency.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
