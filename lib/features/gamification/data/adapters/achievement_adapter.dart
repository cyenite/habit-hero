import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/gamification/domain/models/achievement.dart';

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 5;

  @override
  Achievement read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.readString();
    final iconCode = reader.readInt();
    final colorValue = reader.readString();
    final typeString = reader.readString();
    final xpReward = reader.readInt();
    final unlocked = reader.readBool();
    final hasUnlockedAt = reader.readBool();
    final unlockedAt =
        hasUnlockedAt ? DateTime.parse(reader.readString()) : null;

    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      color: Color(int.parse(colorValue)),
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
      ),
      xpReward: xpReward,
      unlocked: unlocked,
      unlockedAt: unlockedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.icon.codePoint);
    writer.writeString(obj.color.value.toString());
    writer.writeString(obj.type.toString().split('.').last);
    writer.writeInt(obj.xpReward);
    writer.writeBool(obj.unlocked);
    writer.writeBool(obj.unlockedAt != null);
    if (obj.unlockedAt != null) {
      writer.writeString(obj.unlockedAt!.toIso8601String());
    }
  }
}
