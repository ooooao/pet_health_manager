import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

// 数据库服务Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// AI服务Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// 通知服务Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// 当前选中的宠物Provider
final selectedPetProvider = StateProvider<Pet?>((ref) => null);

// 宠物列表Provider
final petsProvider = StateNotifierProvider<PetsNotifier, List<Pet>>((ref) {
  return PetsNotifier(ref.watch(databaseServiceProvider));
});

class PetsNotifier extends StateNotifier<List<Pet>> {
  final DatabaseService _db;

  PetsNotifier(this._db) : super([]);

  void loadPets() {
    state = _db.getAllPets();
  }

  Future<void> addPet(Pet pet) async {
    await _db.addPet(pet);
    loadPets();
  }

  Future<void> updatePet(Pet pet) async {
    await _db.updatePet(pet);
    loadPets();
  }

  Future<void> deletePet(String id) async {
    await _db.deletePet(id);
    loadPets();
  }
}

// 疫苗记录Provider
final vaccineRecordsProvider = StateNotifierProvider.family<VaccineRecordsNotifier, List<VaccineRecord>, String>(
  (ref, petId) {
    return VaccineRecordsNotifier(ref.watch(databaseServiceProvider), petId);
  },
);

class VaccineRecordsNotifier extends StateNotifier<List<VaccineRecord>> {
  final DatabaseService _db;
  final String petId;

  VaccineRecordsNotifier(this._db, this.petId) : super([]) {
    loadRecords();
  }

  void loadRecords() {
    state = _db.getPetVaccineRecords(petId);
  }

  Future<void> addRecord(VaccineRecord record) async {
    await _db.addVaccineRecord(record);
    loadRecords();
  }

  Future<void> updateRecord(VaccineRecord record) async {
    await _db.updateVaccineRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _db.deleteVaccineRecord(id);
    loadRecords();
  }
}

// 驱虫记录Provider
final dewormRecordsProvider = StateNotifierProvider.family<DewormRecordsNotifier, List<DewormRecord>, String>(
  (ref, petId) {
    return DewormRecordsNotifier(ref.watch(databaseServiceProvider), petId);
  },
);

class DewormRecordsNotifier extends StateNotifier<List<DewormRecord>> {
  final DatabaseService _db;
  final String petId;

  DewormRecordsNotifier(this._db, this.petId) : super([]) {
    loadRecords();
  }

  void loadRecords() {
    state = _db.getPetDewormRecords(petId);
  }

  Future<void> addRecord(DewormRecord record) async {
    await _db.addDewormRecord(record);
    loadRecords();
  }

  Future<void> updateRecord(DewormRecord record) async {
    await _db.updateDewormRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _db.deleteDewormRecord(id);
    loadRecords();
  }
}

// 就诊记录Provider
final medicalRecordsProvider = StateNotifierProvider.family<MedicalRecordsNotifier, List<MedicalRecord>, String>(
  (ref, petId) {
    return MedicalRecordsNotifier(ref.watch(databaseServiceProvider), petId);
  },
);

class MedicalRecordsNotifier extends StateNotifier<List<MedicalRecord>> {
  final DatabaseService _db;
  final String petId;

  MedicalRecordsNotifier(this._db, this.petId) : super([]) {
    loadRecords();
  }

  void loadRecords() {
    state = _db.getPetMedicalRecords(petId);
  }

  Future<void> addRecord(MedicalRecord record) async {
    await _db.addMedicalRecord(record);
    loadRecords();
  }

  Future<void> updateRecord(MedicalRecord record) async {
    await _db.updateMedicalRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _db.deleteMedicalRecord(id);
    loadRecords();
  }
}

// 提醒Provider
final remindersProvider = StateNotifierProvider.family<RemindersNotifier, List<Reminder>, String>(
  (ref, petId) {
    return RemindersNotifier(ref.watch(databaseServiceProvider), petId);
  },
);

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final DatabaseService _db;
  final String petId;

  RemindersNotifier(this._db, this.petId) : super([]) {
    loadReminders();
  }

  void loadReminders() {
    state = _db.getPetReminders(petId);
  }

  Future<void> addReminder(Reminder reminder) async {
    await _db.addReminder(reminder);
    loadReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _db.updateReminder(reminder);
    loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _db.deleteReminder(id);
    loadReminders();
  }

  Future<void> toggleComplete(String id) async {
    final reminder = state.firstWhere((r) => r.id == id);
    final updated = Reminder(
      id: reminder.id,
      petId: reminder.petId,
      title: reminder.title,
      type: reminder.type,
      reminderDate: reminder.reminderDate,
      isCompleted: !reminder.isCompleted,
      isRecurring: reminder.isRecurring,
      recurringDays: reminder.recurringDays,
      notes: reminder.notes,
      createdAt: reminder.createdAt,
    );
    await _db.updateReminder(updated);
    loadReminders();
  }
}

// 所有待处理提醒Provider
final allPendingRemindersProvider = Provider<List<Reminder>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllPendingReminders();
});

// 即将到期的提醒Provider
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.getUpcomingReminders();
});
