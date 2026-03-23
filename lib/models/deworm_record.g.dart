part of 'deworm_record.dart';

class DewormRecordAdapter extends TypeAdapter<DewormRecord> {
  @override
  final int typeId = 2;

  @override
  DewormRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DewormRecord(
      id: fields[0] as String,
      petId: fields[1] as String,
      dewormType: fields[2] as String,
      medicineName: fields[3] as String,
      dewormDate: fields[4] as DateTime,
      nextDewormDays: fields[5] as int,
      nextDewormDate: fields[6] as DateTime?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DewormRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.dewormType)
      ..writeByte(3)
      ..write(obj.medicineName)
      ..writeByte(4)
      ..write(obj.dewormDate)
      ..writeByte(5)
      ..write(obj.nextDewormDays)
      ..writeByte(6)
      ..write(obj.nextDewormDate)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DewormRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
