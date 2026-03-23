import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Box<Pet>? _petBox;
  Box<VaccineRecord>? _vaccineBox;
  Box<DewormRecord>? _dewormBox;
  Box<MedicalRecord>? _medicalBox;
  Box<Reminder>? _reminderBox;

  Future<void> init() async {
    // 初始化Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PetAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VaccineRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DewormRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MedicalRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ReminderAdapter());
    }

    // 打开Box
    _petBox = await Hive.openBox<Pet>('pets');
    _vaccineBox = await Hive.openBox<VaccineRecord>('vaccines');
    _dewormBox = await Hive.openBox<DewormRecord>('deworms');
    _medicalBox = await Hive.openBox<MedicalRecord>('medicals');
    _reminderBox = await Hive.openBox<Reminder>('reminders');
  }

  // Pet操作
  Future<String> addPet(Pet pet) async {
    await _petBox?.put(pet.id, pet);
    return pet.id;
  }

  Future<void> updatePet(Pet pet) async {
    await _petBox?.put(pet.id, pet);
  }

  Future<void> deletePet(String id) async {
    await _petBox?.delete(id);
    // 级联删除相关记录
    await deletePetRecords(id);
  }

  Pet? getPet(String id) {
    return _petBox?.get(id);
  }

  List<Pet> getAllPets() {
    return _petBox?.values.toList() ?? [];
  }

  // 级联删除宠物相关记录
  Future<void> deletePetRecords(String petId) async {
    // 删除疫苗记录
    final vaccines = _vaccineBox?.values.where((v) => v.petId == petId).toList() ?? [];
    for (var v in vaccines) {
      await _vaccineBox?.delete(v.id);
    }

    // 删除驱虫记录
    final deworms = _dewormBox?.values.where((d) => d.petId == petId).toList() ?? [];
    for (var d in deworms) {
      await _dewormBox?.delete(d.id);
    }

    // 删除就诊记录
    final medicals = _medicalBox?.values.where((m) => m.petId == petId).toList() ?? [];
    for (var m in medicals) {
      await _medicalBox?.delete(m.id);
    }

    // 删除提醒
    final reminders = _reminderBox?.values.where((r) => r.petId == petId).toList() ?? [];
    for (var r in reminders) {
      await _reminderBox?.delete(r.id);
    }
  }

  // 疫苗记录操作
  Future<String> addVaccineRecord(VaccineRecord record) async {
    await _vaccineBox?.put(record.id, record);
    return record.id;
  }

  Future<void> updateVaccineRecord(VaccineRecord record) async {
    await _vaccineBox?.put(record.id, record);
  }

  Future<void> deleteVaccineRecord(String id) async {
    await _vaccineBox?.delete(id);
  }

  List<VaccineRecord> getPetVaccineRecords(String petId) {
    return _vaccineBox?.values.where((v) => v.petId == petId).toList() ?? [];
  }

  VaccineRecord? getLatestVaccineRecord(String petId) {
    final records = getPetVaccineRecords(petId);
    if (records.isEmpty) return null;
    records.sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
    return records.first;
  }

  // 驱虫记录操作
  Future<String> addDewormRecord(DewormRecord record) async {
    await _dewormBox?.put(record.id, record);
    return record.id;
  }

  Future<void> updateDewormRecord(DewormRecord record) async {
    await _dewormBox?.put(record.id, record);
  }

  Future<void> deleteDewormRecord(String id) async {
    await _dewormBox?.delete(id);
  }

  List<DewormRecord> getPetDewormRecords(String petId) {
    return _dewormBox?.values.where((d) => d.petId == petId).toList() ?? [];
  }

  DewormRecord? getLatestDewormRecord(String petId) {
    final records = getPetDewormRecords(petId);
    if (records.isEmpty) return null;
    records.sort((a, b) => b.dewormDate.compareTo(a.dewormDate));
    return records.first;
  }

  // 就诊记录操作
  Future<String> addMedicalRecord(MedicalRecord record) async {
    await _medicalBox?.put(record.id, record);
    return record.id;
  }

  Future<void> updateMedicalRecord(MedicalRecord record) async {
    await _medicalBox?.put(record.id, record);
  }

  Future<void> deleteMedicalRecord(String id) async {
    await _medicalBox?.delete(id);
  }

  List<MedicalRecord> getPetMedicalRecords(String petId) {
    return _medicalBox?.values.where((m) => m.petId == petId).toList() ?? [];
  }

  // 提醒操作
  Future<String> addReminder(Reminder reminder) async {
    await _reminderBox?.put(reminder.id, reminder);
    return reminder.id;
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _reminderBox?.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _reminderBox?.delete(id);
  }

  List<Reminder> getPetReminders(String petId) {
    return _reminderBox?.values.where((r) => r.petId == petId).toList() ?? [];
  }

  List<Reminder> getAllPendingReminders() {
    return _reminderBox?.values.where((r) => !r.isCompleted).toList() ?? [];
  }

  List<Reminder> getOverdueReminders() {
    final now = DateTime.now();
    return _reminderBox?.values.where((r) {
      if (r.isCompleted) return false;
      return r.reminderDate.isBefore(now);
    }).toList() ?? [];
  }

  // 获取即将到期的提醒（7天内）
  List<Reminder> getUpcomingReminders({int days = 7}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return _reminderBox?.values.where((r) {
      if (r.isCompleted) return false;
      return r.reminderDate.isAfter(now) && r.reminderDate.isBefore(future);
    }).toList() ?? [];
  }

  // 关闭数据库
  Future<void> close() async {
    await _petBox?.close();
    await _vaccineBox?.close();
    await _dewormBox?.close();
    await _medicalBox?.close();
    await _reminderBox?.close();
  }
}
