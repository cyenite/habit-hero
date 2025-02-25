// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Convert color value to string if it's an int
    final colorValue = fields[11];
    final colorValueString =
        colorValue is int ? colorValue.toString() : colorValue;

    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      frequency: fields[3] as HabitFrequency,
      selectedDays: (fields[4] as List).cast<bool>(),
      reminderTime: fields[5] as TimeOfDay,
      createdAt: fields[6] as DateTime,
      streak: fields[7] as int,
      level: fields[8] as int,
      progress: fields[9] as double,
      icon: IconData(fields[10] as int, fontFamily: 'MaterialIcons'),
      color: Color(int.parse(colorValueString as String)),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.colorValue);
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
