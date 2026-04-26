// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name:            fields[0]  as String,
      countryId:       fields[1]  as String,
      lifeStage:       fields[2]  as String,
      primaryIncome:   fields[3]  as double,
      secondaryIncome: fields[4]  as double,
      extraIncome:     fields[5]  as double,
      onboarded:       fields[6]  as bool,
      streakCount:     fields[7]  as int,
      lastLogDate:     fields[8]  as String,
      bestStreak:      fields[9]  as String,
      rescueTokens:    fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)  ..write(obj.name)
      ..writeByte(1)  ..write(obj.countryId)
      ..writeByte(2)  ..write(obj.lifeStage)
      ..writeByte(3)  ..write(obj.primaryIncome)
      ..writeByte(4)  ..write(obj.secondaryIncome)
      ..writeByte(5)  ..write(obj.extraIncome)
      ..writeByte(6)  ..write(obj.onboarded)
      ..writeByte(7)  ..write(obj.streakCount)
      ..writeByte(8)  ..write(obj.lastLogDate)
      ..writeByte(9)  ..write(obj.bestStreak)
      ..writeByte(10) ..write(obj.rescueTokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
