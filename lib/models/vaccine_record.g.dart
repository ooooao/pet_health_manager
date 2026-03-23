part of 'vaccine_record.dart';

class VaccineRecordAdapter extends TypeAdapter<VaccineRecord> {
  @override
  final int typeId = 1;

  @override
  VaccineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineRecord(
      id: fields[0] as String,
      petId: fields[1] as String,
      vaccineType: fields[2] as String,
      vaccinationDate: fields[3] as DateTime,
      hospital: fields[4] as String?,
      validityDays: fields[5] as int,
      nextVaccinationDate: fields[6] as DateTime?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.vaccineType)
      ..writeByte(3)
      ..write(obj.vaccinationDate)
      ..writeByte(4)
      ..write(obj.hospital)
      ..writeByte(5)
      ..write(obj.validityDays)
      ..writeByte(6)
      ..write(obj.nextVaccinationDate)
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
      other is VaccineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
