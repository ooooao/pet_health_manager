import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'pet.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String species;

  @HiveField(3)
  String breed;

  @HiveField(4)
  String gender;

  @HiveField(5)
  DateTime birthday;

  @HiveField(6)
  double weight;

  @HiveField(7)
  String color;

  @HiveField(8)
  String? chipNumber;

  @HiveField(9)
  String? avatarPath;

  @HiveField(10)
  DateTime createdAt;

  Pet({
    String? id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthday,
    required this.weight,
    required this.color,
    this.chipNumber,
    this.avatarPath,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // 计算年龄
  String get age {
    final now = DateTime.now();
    int years = now.year - birthday.year;
    int months = now.month - birthday.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return months > 0 ? '$years岁$months个月' : '$years岁';
    } else {
      return '$months个月';
    }
  }

  // 获取年龄月数（用于计算）
  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthday.year) * 12 + (now.month - birthday.month);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birthday': birthday.toIso8601String(),
      'weight': weight,
      'color': color,
      'chipNumber': chipNumber,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      gender: json['gender'],
      birthday: DateTime.parse(json['birthday']),
      weight: json['weight'].toDouble(),
      color: json['color'],
      chipNumber: json['chipNumber'],
      avatarPath: json['avatarPath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? birthday,
    double? weight,
    String? color,
    String? chipNumber,
    String? avatarPath,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      chipNumber: chipNumber ?? this.chipNumber,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
    );
  }
}
