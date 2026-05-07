// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionGoalAdapter extends TypeAdapter<NutritionGoal> {
  @override
  final int typeId = 2;

  @override
  NutritionGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoal(
      targetCalories: fields[0] as double,
      targetProtein: fields[1] as double?,
      targetCarbs: fields[2] as double?,
      targetFats: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionGoal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.targetCalories)
      ..writeByte(1)
      ..write(obj.targetProtein)
      ..writeByte(2)
      ..write(obj.targetCarbs)
      ..writeByte(3)
      ..write(obj.targetFats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
