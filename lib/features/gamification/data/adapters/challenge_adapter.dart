import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/gamification/domain/models/challenge.dart';

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 4; // Use a unique ID

  @override
  Challenge read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final iconCode = reader.readInt();
    final colorValue = reader.readString();
    final xpReward = reader.readInt();
    final expiresAt = DateTime.parse(reader.readString());
    final completed = reader.readBool();
    final hasCompletedAt = reader.readBool();
    final completedAt =
        hasCompletedAt ? DateTime.parse(reader.readString()) : null;

    return Challenge(
      id: id,
      title: title,
      description: description,
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      color: Color(int.parse(colorValue)),
      xpReward: xpReward,
      expiresAt: expiresAt,
      completed: completed,
      completedAt: completedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.icon.codePoint);
    writer.writeString(obj.color.value.toString());
    writer.writeInt(obj.xpReward);
    writer.writeString(obj.expiresAt.toIso8601String());
    writer.writeBool(obj.completed);
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeString(obj.completedAt!.toIso8601String());
    }
  }
}
