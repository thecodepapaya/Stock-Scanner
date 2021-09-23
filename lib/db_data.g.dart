// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbDataAdapter extends TypeAdapter<DbData> {
  @override
  final int typeId = 0;

  @override
  DbData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbData()
      ..filePath = fields[0] as String?
      ..barcodeData = fields[1] as String?
      ..sheetId = fields[2] as String?
      ..timestamp = fields[3] as String?
      ..isUploaded = fields[4] as bool?;
  }

  @override
  void write(BinaryWriter writer, DbData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.barcodeData)
      ..writeByte(2)
      ..write(obj.sheetId)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isUploaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
