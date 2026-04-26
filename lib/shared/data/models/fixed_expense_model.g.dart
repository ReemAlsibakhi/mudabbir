// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_expense_model.dart';

class FixedExpenseModelAdapter extends TypeAdapter<FixedExpenseModel> {
  @override
  final int typeId = 3;

  @override
  FixedExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedExpenseModel(
      id:            fields[0] as String,
      categoryId:    fields[1] as String,
      name:          fields[2] as String,
      amount:        fields[3] as double,
      active:        fields[4] as bool,
      createdAt:     fields[5] as DateTime,
      dueDayOfMonth: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FixedExpenseModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0) ..write(obj.id)
      ..writeByte(1) ..write(obj.categoryId)
      ..writeByte(2) ..write(obj.name)
      ..writeByte(3) ..write(obj.amount)
      ..writeByte(4) ..write(obj.active)
      ..writeByte(5) ..write(obj.createdAt)
      ..writeByte(6) ..write(obj.dueDayOfMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
