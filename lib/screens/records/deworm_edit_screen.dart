import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class DewormEditScreen extends ConsumerStatefulWidget {
  final String? petId;
  final DewormRecord? record;

  const DewormEditScreen({super.key, this.petId, this.record});

  @override
  ConsumerState<DewormEditScreen> createState() => _DewormEditScreenState();
}

class _DewormEditScreenState extends ConsumerState<DewormEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineController = TextEditingController();
  final _notesController = TextEditingController();

  String _dewormType = '体内驱虫';
  DateTime _dewormDate = DateTime.now();
  int _nextDewormDays = 90;

  final List<String> _dewormTypes = ['体内驱虫', '体外驱虫', '内外同驱'];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _dewormType = widget.record!.dewormType;
      _dewormDate = widget.record!.dewormDate;
      _nextDewormDays = widget.record!.nextDewormDays;
      _medicineController.text = widget.record!.medicineName;
      _notesController.text = widget.record!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dewormDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dewormDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final record = DewormRecord(
      id: widget.record?.id,
      petId: widget.record?.petId ?? widget.petId!,
      dewormType: _dewormType,
      medicineName: _medicineController.text.trim(),
      dewormDate: _dewormDate,
      nextDewormDays: _nextDewormDays,
      nextDewormDate: _dewormDate.add(Duration(days: _nextDewormDays)),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.record?.createdAt,
    );

    // 创建提醒
    final reminder = Reminder(
      petId: record.petId,
      title: '${_dewormType}提醒',
      type: Reminder.typeDeworm,
      reminderDate: record.nextDewormDate!,
      notes: '请按时为宠物驱虫',
    );

    if (widget.record == null) {
      await ref.read(dewormRecordsProvider(record.petId).notifier).addRecord(record);
      await ref.read(remindersProvider(record.petId).notifier).addReminder(reminder);
    } else {
      await ref.read(dewormRecordsProvider(record.petId).notifier).updateRecord(record);
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
          isEditing ? '编辑驱虫记录' : '添加驱虫记录',
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
            _buildDewormTypeSelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '药品名称 *',
              hint: '如：大宠爱、福来恩等',
              controller: _medicineController,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入药品名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildIntervalSelector(),
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

  Widget _buildDewormTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '驱虫类型',
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
          children: _dewormTypes.map((type) {
            final isSelected = _dewormType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _dewormType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
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
          '驱虫日期',
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
                  '${_dewormDate.year}-${_dewormDate.month}-${_dewormDate.day}',
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

  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '下次驱虫间隔',
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
            {'label': '1个月', 'days': 30},
            {'label': '3个月', 'days': 90},
            {'label': '6个月', 'days': 180},
          ].map((item) {
            final isSelected = _nextDewormDays == item['days'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _nextDewormDays = item['days'] as int;
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
