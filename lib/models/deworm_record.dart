import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'deworm_record.g.dart';

@HiveType(typeId: 2)
class DewormRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String dewormType;

  @HiveField(3)
  String medicineName;

  @HiveField(4)
  DateTime dewormDate;

  @HiveField(5)
  int nextDewormDays;

  @HiveField(6)
  DateTime? nextDewormDate;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  DewormRecord({
    String? id,
    required this.petId,
    required this.dewormType,
    required this.medicineName,
    required this.dewormDate,
    required this.nextDewormDays,
    this.nextDewormDate,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now() {
    nextDewormDate ??= dewormDate.add(Duration(days: nextDewormDays));
  }

  int get status {
    if (nextDewormDate == null) return 2;
    final now = DateTime.now();
    final diff = nextDewormDate!.difference(now).inDays;
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
      'dewormType': dewormType,
      'medicineName': medicineName,
      'dewormDate': dewormDate.toIso8601String(),
      'nextDewormDays': nextDewormDays,
      'nextDewormDate': nextDewormDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
