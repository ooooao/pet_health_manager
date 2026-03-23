import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../pet/pet_detail_screen.dart';
import '../pet/pet_edit_screen.dart';
import '../records/health_records_screen.dart';
import '../ai/ai_report_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petsProvider.notifier).loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petsProvider);
    final selectedPet = ref.watch(selectedPetProvider);
    final upcomingReminders = ref.watch(upcomingRemindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: pets.isEmpty
            ? _buildEmptyState()
            : CustomScrollView(
                slivers: [
                  _buildAppBar(pets, selectedPet),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppStyles.padding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (upcomingReminders.isNotEmpty) ...[
                          _buildRemindersSection(upcomingReminders),
                          const SizedBox(height: 20),
                        ],
                        _buildQuickActions(selectedPet),
                        const SizedBox(height: 20),
                        if (selectedPet != null) ...[
                          _buildHealthOverview(selectedPet),
                          const SizedBox(height: 20),
                        ],
                        _buildPetList(pets),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: CupertinoIcons.paw,
      title: '还没有宠物档案',
      subtitle: '添加您的第一只宠物，开始记录它的健康生活',
      action: IOSButton(
        text: '添加宠物',
        icon: CupertinoIcons.add,
        onPressed: () => _addPet(),
      ),
    );
  }

  Widget _buildAppBar(List<Pet> pets, Pet? selectedPet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '宠康管家',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      pets.isEmpty ? '管理您的宠物健康' : '${pets.length}只宠物',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.settings,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (selectedPet != null) ...[
              const SizedBox(height: 16),
              _buildSelectedPetCard(selectedPet),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPetCard(Pet pet) {
    return IOSCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: pet.avatarPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(pet.avatarPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    CupertinoIcons.paw,
                    color: AppColors.primary,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.species} · ${pet.breed} · ${pet.age}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.textHint,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(List<Reminder> reminders) {
    final urgentReminders = reminders.where((r) => r.status <= 1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.bell_fill,
              color: AppColors.warning,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              '待办提醒',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (urgentReminders.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${urgentReminders.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...reminders.take(3).map((r) => _buildReminderItem(r)),
      ],
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    final pet = ref.read(databaseServiceProvider).getPet(reminder.petId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reminder.status == 0
            ? AppColors.error.withOpacity(0.1)
            : reminder.status == 1
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.status == 0
              ? AppColors.error.withOpacity(0.3)
              : reminder.status == 1
                  ? AppColors.warning.withOpacity(0.3)
                  : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: reminder.status == 0
                  ? AppColors.error.withOpacity(0.15)
                  : reminder.status == 1
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getReminderIcon(reminder.type),
              color: reminder.status == 0
                  ? AppColors.error
                  : reminder.status == 1
                      ? AppColors.warning
                      : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pet?.name ?? ''} · ${reminder.typeText}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(
            text: reminder.status == 0
                ? '已逾期'
                : reminder.status == 1
                    ? '今天'
                    : '${reminder.reminderDate.difference(DateTime.now()).inDays}天后',
            status: reminder.status,
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case Reminder.typeVaccine:
        return CupertinoIcons.eyedropper;
      case Reminder.typeDeworm:
        return CupertinoIcons.bandage;
      case Reminder.typeMedical:
        return CupertinoIcons.heart;
      case Reminder.typeBath:
        return CupertinoIcons.drop;
      case Reminder.typeNail:
        return CupertinoIcons.scissors;
      case Reminder.typeFeed:
        return CupertinoIcons.clock;
      default:
        return CupertinoIcons.bell;
    }
  }

  Widget _buildQuickActions(Pet? selectedPet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷入口',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: CupertinoIcons.add_circled,
                label: '添加记录',
                onTap: selectedPet != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthRecordsScreen(pet: selectedPet),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: CupertinoIcons.doc_text,
                label: '生成报告',
                onTap: selectedPet != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIReportScreen(pet: selectedPet),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: CupertinoIcons.add,
                label: '添加宠物',
                onTap: () => _addPet(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.surface : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: onTap != null ? AppColors.primary : AppColors.textHint,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: onTap != null ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview(Pet pet) {
    final vaccineRecord = ref.read(databaseServiceProvider).getLatestVaccineRecord(pet.id);
    final dewormRecord = ref.read(databaseServiceProvider).getLatestDewormRecord(pet.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健康概览',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthCard(
                icon: CupertinoIcons.eyedropper,
                title: '疫苗',
                status: vaccineRecord?.statusText ?? '未记录',
                statusCode: vaccineRecord?.status ?? 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthCard(
                icon: CupertinoIcons.bandage,
                title: '驱虫',
                status: dewormRecord?.statusText ?? '未记录',
                statusCode: dewormRecord?.status ?? 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required String status,
    required int statusCode,
  }) {
    Color statusColor;
    switch (statusCode) {
      case 0:
        statusColor = AppColors.error;
        break;
      case 1:
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(List<Pet> pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '我的宠物',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _addPet(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.add,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '添加',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pets.map((pet) => _buildPetListItem(pet)),
      ],
    );
  }

  Widget _buildPetListItem(Pet pet) {
    final isSelected = ref.watch(selectedPetProvider)?.id == pet.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedPetProvider.notifier).state = pet;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: pet.avatarPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(pet.avatarPath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      CupertinoIcons.paw,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.species} · ${pet.breed}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addPet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PetEditScreen()),
    );
  }
}
