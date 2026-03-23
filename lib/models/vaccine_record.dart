import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'vaccine_record.g.dart';

@HiveType(typeId: 1)
class VaccineRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String vaccineType;

  @HiveField(3)
  DateTime vaccinationDate;

  @HiveField(4)
  String? hospital;

  @HiveField(5)
  int validityDays;

  @HiveField(6)
  DateTime? nextVaccinationDate;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  VaccineRecord({
    String? id,
    required this.petId,
    required this.vaccineType,
    required this.vaccinationDate,
    this.hospital,
    required this.validityDays,
    this.nextVaccinationDate,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now() {
    // 自动计算下次接种日期
    nextVaccinationDate ??= vaccinationDate.add(Duration(days: validityDays));
  }

  // 获取状态：0-已过期, 1-即将到期(7天内), 2-正常
  int get status {
    if (nextVaccinationDate == null) return 2;
    final now = DateTime.now();
    final diff = nextVaccinationDate!.difference(now).inDays;
    if (diff < 0) return 0;
    if (diff <= 7) return 1;
    return 2;
  }

  String get statusText {
    switch (status) {
      case 0:
        return '已过期';
      case 1:
        return '即将到期';
      default:
        return '正常';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'vaccineType': vaccineType,
      'vaccinationDate': vaccinationDate.toIso8601String(),
      'hospital': hospital,
      'validityDays': validityDays,
      'nextVaccinationDate': nextVaccinationDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
