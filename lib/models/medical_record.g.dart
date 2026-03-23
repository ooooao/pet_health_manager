part of 'medical_record.dart';

class MedicalRecordAdapter extends TypeAdapter<MedicalRecord> {
  @override
  final int typeId = 3;

  @override
  MedicalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecord(
      id: fields[0] as String,
      petId: fields[1] as String,
      visitDate: fields[2] as DateTime,
      hospitalName: fields[3] as String,
      symptoms: fields[4] as String,
      diagnosis: fields[5] as String,
      prescription: fields[6] as String?,
      cost: fields[7] as double?,
      photos: (fields[8] as List?)?.cast<String>(),
      followUpDate: fields[9] as DateTime?,
      notes: fields[10] as String?,
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.visitDate)
      ..writeByte(3)
      ..write(obj.hospitalName)
      ..writeByte(4)
      ..write(obj.symptoms)
      ..writeByte(5)
      ..write(obj.diagnosis)
      ..writeByte(6)
      ..write(obj.prescription)
      ..writeByte(7)
      ..write(obj.cost)
      ..writeByte(8)
      ..write(obj.photos)
      ..writeByte(9)
      ..write(obj.followUpDate)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
