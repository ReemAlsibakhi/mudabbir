// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 4;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id:            fields[0] as String,
      type:          fields[1] as String,
      name:          fields[2] as String,
      target:        fields[3] as double,
      saved:         fields[4] as double,
      monthlyTarget: fields[5] as double,
      targetMonths:  fields[6] as int?,
      createdAt:     fields[7] as DateTime,
      completed:     fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0) ..write(obj.id)
      ..writeByte(1) ..write(obj.type)
      ..writeByte(2) ..write(obj.name)
      ..writeByte(3) ..write(obj.target)
      ..writeByte(4) ..write(obj.saved)
      ..writeByte(5) ..write(obj.monthlyTarget)
      ..writeByte(6) ..write(obj.targetMonths)
      ..writeByte(7) ..write(obj.createdAt)
      ..writeByte(8) ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
