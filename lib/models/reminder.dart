import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reminder.g.dart';

@HiveType(typeId: 4)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String type;

  @HiveField(4)
  DateTime reminderDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  int? recurringDays;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime createdAt;

  Reminder({
    String? id,
    required this.petId,
    required this.title,
    required this.type,
    required this.reminderDate,
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringDays,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // 提醒类型常量
  static const String typeVaccine = 'vaccine';
  static const String typeDeworm = 'deworm';
  static const String typeMedical = 'medical';
  static const String typeBath = 'bath';
  static const String typeNail = 'nail';
  static const String typeFeed = 'feed';
  static const String typeCustom = 'custom';

  String get typeText {
    switch (type) {
      case typeVaccine:
        return '疫苗';
      case typeDeworm:
        return '驱虫';
      case typeMedical:
        return '就诊';
      case typeBath:
        return '洗澡';
      case typeNail:
        return '剪指甲';
      case typeFeed:
        return '喂食';
      default:
        return '自定义';
    }
  }

  // 获取状态：0-已过期未完成, 1-今天到期, 2-即将到期(7天内), 3-正常
  int get status {
    if (isCompleted) return 4;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

    if (reminderDay.isBefore(today)) return 0;
    if (reminderDay.isAtSameMomentAs(today)) return 1;

    final diff = reminderDay.difference(today).inDays;
    if (diff <= 7) return 2;
    return 3;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'type': type,
      'reminderDate': reminderDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
