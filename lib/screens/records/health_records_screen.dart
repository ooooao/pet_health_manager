import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'vaccine_edit_screen.dart';
import 'deworm_edit_screen.dart';
import 'medical_edit_screen.dart';

class HealthRecordsScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const HealthRecordsScreen({super.key, required this.pet});

  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.pet.name}的健康记录',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '疫苗'),
            Tab(text: '驱虫'),
            Tab(text: '就诊'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VaccineTab(pet: widget.pet),
          _DewormTab(pet: widget.pet),
          _MedicalTab(pet: widget.pet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _addRecord(),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }

  void _addRecord() {
    switch (_tabController.index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VaccineEditScreen(petId: widget.pet.id),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DewormEditScreen(petId: widget.pet.id),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicalEditScreen(petId: widget.pet.id),
          ),
        );
        break;
    }
  }
}

// 疫苗记录Tab
class _VaccineTab extends ConsumerWidget {
  final Pet pet;

  const _VaccineTab({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(vaccineRecordsProvider(pet.id));

    if (records.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.eyedropper,
        title: '还没有疫苗记录',
        subtitle: '记录疫苗接种信息，到期自动提醒',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.padding),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildVaccineCard(context, ref, record);
      },
    );
  }

  Widget _buildVaccineCard(BuildContext context, WidgetRef ref, VaccineRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.eyedropper,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    record.vaccineType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(text: record.statusText, status: record.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('接种日期', '${record.vaccinationDate.year}-${record.vaccinationDate.month}-${record.vaccinationDate.day}'),
          _buildInfoRow('接种医院', record.hospital ?? '未填写'),
          _buildInfoRow('下次接种', record.nextVaccinationDate != null
              ? '${record.nextVaccinationDate!.year}-${record.nextVaccinationDate!.month}-${record.nextVaccinationDate!.day}'
              : '未设置'),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '备注：${record.notes}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VaccineEditScreen(record: record),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.pencil, size: 16),
                  label: const Text('编辑'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteRecord(context, ref, record),
                  icon: const Icon(CupertinoIcons.trash, size: 16, color: AppColors.error),
                  label: const Text('删除', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, VaccineRecord record) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条疫苗记录吗？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              ref.read(vaccineRecordsProvider(pet.id).notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// 驱虫记录Tab
class _DewormTab extends ConsumerWidget {
  final Pet pet;

  const _DewormTab({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(dewormRecordsProvider(pet.id));

    if (records.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.bandage,
        title: '还没有驱虫记录',
        subtitle: '记录驱虫信息，守护宠物健康',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.padding),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildDewormCard(context, ref, record);
      },
    );
  }

  Widget _buildDewormCard(BuildContext context, WidgetRef ref, DewormRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.bandage,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    record.dewormType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(text: record.statusText, status: record.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('驱虫日期', '${record.dewormDate.year}-${record.dewormDate.month}-${record.dewormDate.day}'),
          _buildInfoRow('药品名称', record.medicineName),
          _buildInfoRow('下次驱虫', record.nextDewormDate != null
              ? '${record.nextDewormDate!.year}-${record.nextDewormDate!.month}-${record.nextDewormDate!.day}'
              : '未设置'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DewormEditScreen(record: record),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.pencil, size: 16),
                  label: const Text('编辑'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteRecord(context, ref, record),
                  icon: const Icon(CupertinoIcons.trash, size: 16, color: AppColors.error),
                  label: const Text('删除', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, DewormRecord record) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条驱虫记录吗？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              ref.read(dewormRecordsProvider(pet.id).notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// 就诊记录Tab
class _MedicalTab extends ConsumerWidget {
  final Pet pet;

  const _MedicalTab({required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(medicalRecordsProvider(pet.id));

    if (records.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.heart,
        title: '还没有就诊记录',
        subtitle: '记录每次就诊详情，方便复诊参考',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.padding),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildMedicalCard(context, ref, record);
      },
    );
  }

  Widget _buildMedicalCard(BuildContext context, WidgetRef ref, MedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.heart,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.visitDate.year}-${record.visitDate.month}-${record.visitDate.day}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      record.hospitalName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (record.cost != null)
                Text(
                  '¥${record.cost!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildMedicalInfo('症状', record.symptoms),
          _buildMedicalInfo('诊断', record.diagnosis),
          if (record.prescription != null && record.prescription!.isNotEmpty)
            _buildMedicalInfo('处方', record.prescription!),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicalEditScreen(record: record),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.pencil, size: 16),
                  label: const Text('编辑'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteRecord(context, ref, record),
                  icon: const Icon(CupertinoIcons.trash, size: 16, color: AppColors.error),
                  label: const Text('删除', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, MedicalRecord record) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条就诊记录吗？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              ref.read(medicalRecordsProvider(pet.id).notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
