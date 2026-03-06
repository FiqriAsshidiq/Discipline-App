// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_status_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityStatusModelAdapter extends TypeAdapter<ActivityStatusModel> {
  @override
  final int typeId = 1;

  @override
  ActivityStatusModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityStatusModel(
      scheduleKey: fields[0] as String,
      date: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityStatusModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.scheduleKey)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
