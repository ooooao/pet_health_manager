import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'medical_record.g.dart';

@HiveType(typeId: 3)
class MedicalRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime visitDate;

  @HiveField(3)
  String hospitalName;

  @HiveField(4)
  String symptoms;

  @HiveField(5)
  String diagnosis;

  @HiveField(6)
  String? prescription;

  @HiveField(7)
  double? cost;

  @HiveField(8)
  List<String> photos;

  @HiveField(9)
  DateTime? followUpDate;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  MedicalRecord({
    String? id,
    required this.petId,
    required this.visitDate,
    required this.hospitalName,
    required this.symptoms,
    required this.diagnosis,
    this.prescription,
    this.cost,
    List<String>? photos,
    this.followUpDate,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        photos = photos ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'visitDate': visitDate.toIso8601String(),
      'hospitalName': hospitalName,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'cost': cost,
      'photos': photos,
      'followUpDate': followUpDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
