import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'pet_edit_screen.dart';
import '../records/health_records_screen.dart';
import '../ai/ai_report_screen.dart';

class PetDetailScreen extends ConsumerWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccineRecords = ref.watch(vaccineRecordsProvider(pet.id));
    final dewormRecords = ref.watch(dewormRecordsProvider(pet.id));
    final medicalRecords = ref.watch(medicalRecordsProvider(pet.id));

    final latestVaccine = vaccineRecords.isNotEmpty
        ? (vaccineRecords..sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate))).first
        : null;
    final latestDeworm = dewormRecords.isNotEmpty
        ? (dewormRecords..sort((a, b) => b.dewormDate.compareTo(a.dewormDate))).first
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.pencil, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetEditScreen(pet: pet)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(45),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: pet.avatarPath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(pet.avatarPath!),
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                ),
                              )
                            : const Icon(
                                CupertinoIcons.paw,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.species} · ${pet.breed} · ${pet.age}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppStyles.padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildHealthStatusCard(latestVaccine, latestDeworm),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildRecordSummary(vaccineRecords, dewormRecords, medicalRecords),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return IOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('性别', pet.gender),
          _buildInfoRow('毛色', pet.color),
          _buildInfoRow('体重', '${pet.weight} kg'),
          _buildInfoRow('芯片编号', pet.chipNumber ?? '未登记'),
          _buildInfoRow('建档日期', '${pet.createdAt.year}-${pet.createdAt.month}-${pet.createdAt.day}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(VaccineRecord? vaccine, DewormRecord? deworm) {
    return IOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '健康状态',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            icon: CupertinoIcons.eyedropper,
            title: '疫苗接种',
            status: vaccine?.statusText ?? '未记录',
            statusCode: vaccine?.status ?? 2,
            date: vaccine?.nextVaccinationDate != null
                ? '下次：${vaccine!.nextVaccinationDate!.year}-${vaccine.nextVaccinationDate!.month}-${vaccine.nextVaccinationDate!.day}'
                : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildStatusRow(
            icon: CupertinoIcons.bandage,
            title: '驱虫记录',
            status: deworm?.statusText ?? '未记录',
            statusCode: deworm?.status ?? 2,
            date: deworm?.nextDewormDate != null
                ? '下次：${deworm!.nextDewormDate!.year}-${deworm.nextDewormDate!.month}-${deworm.nextDewormDate!.day}'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String status,
    required int statusCode,
    String? date,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (date != null)
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        StatusBadge(text: status, status: statusCode),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: CupertinoIcons.doc_text,
                label: '健康记录',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthRecordsScreen(pet: pet),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: CupertinoIcons.chart_bar,
                label: 'AI报告',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIReportScreen(pet: pet),
                  ),
                ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSummary(
    List<VaccineRecord> vaccines,
    List<DewormRecord> deworms,
    List<MedicalRecord> medicals,
  ) {
    return IOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '记录统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.eyedropper,
                  count: vaccines.length,
                  label: '疫苗记录',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.bandage,
                  count: deworms.length,
                  label: '驱虫记录',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.heart,
                  count: medicals.length,
                  label: '就诊记录',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary.withOpacity(0.6), size: 24),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
