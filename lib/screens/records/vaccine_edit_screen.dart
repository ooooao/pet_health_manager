import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class VaccineEditScreen extends ConsumerStatefulWidget {
  final String? petId;
  final VaccineRecord? record;

  const VaccineEditScreen({super.key, this.petId, this.record});

  @override
  ConsumerState<VaccineEditScreen> createState() => _VaccineEditScreenState();
}

class _VaccineEditScreenState extends ConsumerState<VaccineEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _notesController = TextEditingController();

  String _vaccineType = '狂犬疫苗';
  DateTime _vaccinationDate = DateTime.now();
  int _validityDays = 365;

  final List<Map<String, dynamic>> _vaccineTypes = [
    {'name': '狂犬疫苗', 'validity': 365},
    {'name': '猫三联', 'validity': 365},
    {'name': '妙三多', 'validity': 365},
    {'name': '卫佳捌', 'validity': 365},
    {'name': '卫佳伍', 'validity': 365},
    {'name': '其他', 'validity': 365},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _vaccineType = widget.record!.vaccineType;
      _vaccinationDate = widget.record!.vaccinationDate;
      _validityDays = widget.record!.validityDays;
      _hospitalController.text = widget.record!.hospital ?? '';
      _notesController.text = widget.record!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vaccinationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _vaccinationDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final record = VaccineRecord(
      id: widget.record?.id,
      petId: widget.record?.petId ?? widget.petId!,
      vaccineType: _vaccineType,
      vaccinationDate: _vaccinationDate,
      hospital: _hospitalController.text.trim().isEmpty ? null : _hospitalController.text.trim(),
      validityDays: _validityDays,
      nextVaccinationDate: _vaccinationDate.add(Duration(days: _validityDays)),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.record?.createdAt,
    );

    // 创建提醒
    final reminder = Reminder(
      petId: record.petId,
      title: '${_vaccineType}接种提醒',
      type: Reminder.typeVaccine,
      reminderDate: record.nextVaccinationDate!,
      notes: '请按时为宠物接种疫苗',
    );

    if (widget.record == null) {
      await ref.read(vaccineRecordsProvider(record.petId).notifier).addRecord(record);
      await ref.read(remindersProvider(record.petId).notifier).addReminder(reminder);
    } else {
      await ref.read(vaccineRecordsProvider(record.petId).notifier).updateRecord(record);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

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
          isEditing ? '编辑疫苗记录' : '添加疫苗记录',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppStyles.padding),
          children: [
            _buildVaccineTypeSelector(),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '接种医院',
              hint: '请输入接种医院名称',
              controller: _hospitalController,
            ),
            const SizedBox(height: 20),
            _buildValiditySelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '备注',
              hint: '可选填',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            IOSButton(
              text: '保存',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '疫苗类型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _vaccineTypes.map((type) {
            final isSelected = _vaccineType == type['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _vaccineType = type['name'];
                  _validityDays = type['validity'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '接种日期',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_vaccinationDate.year}-${_vaccinationDate.month}-${_vaccinationDate.day}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValiditySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '有效期（天）',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            {'label': '1年', 'days': 365},
            {'label': '3年', 'days': 1095},
            {'label': '1个月', 'days': 30},
            {'label': '3个月', 'days': 90},
          ].map((item) {
            final isSelected = _validityDays == item['days'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _validityDays = item['days'] as int;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
