import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class MedicalEditScreen extends ConsumerStatefulWidget {
  final String? petId;
  final MedicalRecord? record;

  const MedicalEditScreen({super.key, this.petId, this.record});

  @override
  ConsumerState<MedicalEditScreen> createState() => _MedicalEditScreenState();
}

class _MedicalEditScreenState extends ConsumerState<MedicalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _visitDate = DateTime.now();
  DateTime? _followUpDate;
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _visitDate = widget.record!.visitDate;
      _followUpDate = widget.record!.followUpDate;
      _hospitalController.text = widget.record!.hospitalName;
      _symptomsController.text = widget.record!.symptoms;
      _diagnosisController.text = widget.record!.diagnosis;
      _prescriptionController.text = widget.record!.prescription ?? '';
      _costController.text = widget.record!.cost?.toString() ?? '';
      _notesController.text = widget.record!.notes ?? '';
      _photos = List.from(widget.record!.photos);
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _selectFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photos.add(picked.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final record = MedicalRecord(
      id: widget.record?.id,
      petId: widget.record?.petId ?? widget.petId!,
      visitDate: _visitDate,
      hospitalName: _hospitalController.text.trim(),
      symptoms: _symptomsController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      prescription: _prescriptionController.text.trim().isEmpty
          ? null
          : _prescriptionController.text.trim(),
      cost: double.tryParse(_costController.text),
      photos: _photos,
      followUpDate: _followUpDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.record?.createdAt,
    );

    // 如果有复诊日期，创建提醒
    if (_followUpDate != null) {
      final reminder = Reminder(
        petId: record.petId,
        title: '复诊提醒',
        type: Reminder.typeMedical,
        reminderDate: _followUpDate!,
        notes: '请按时带宠物复诊',
      );
      await ref.read(remindersProvider(record.petId).notifier).addReminder(reminder);
    }

    if (widget.record == null) {
      await ref.read(medicalRecordsProvider(record.petId).notifier).addRecord(record);
    } else {
      await ref.read(medicalRecordsProvider(record.petId).notifier).updateRecord(record);
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
          isEditing ? '编辑就诊记录' : '添加就诊记录',
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
            _buildDateSelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '医院名称 *',
              hint: '请输入就诊医院',
              controller: _hospitalController,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入医院名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '症状描述 *',
              hint: '请描述宠物的症状',
              controller: _symptomsController,
              maxLines: 3,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入症状描述';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '诊断结果 *',
              hint: '请输入医生的诊断结果',
              controller: _diagnosisController,
              maxLines: 2,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入诊断结果';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '处方用药',
              hint: '请输入医生开具的药物',
              controller: _prescriptionController,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '费用（元）',
              hint: '可选填',
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            _buildFollowUpDateSelector(),
            const SizedBox(height: 20),
            _buildPhotosSection(),
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '就诊日期',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectVisitDate,
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
                  '${_visitDate.year}-${_visitDate.month}-${_visitDate.day}',
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

  Widget _buildFollowUpDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '复诊日期',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (_followUpDate != null)
              TextButton(
                onPressed: () => setState(() => _followUpDate = null),
                child: const Text('清除'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectFollowUpDate,
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
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _followUpDate != null
                      ? '${_followUpDate!.year}-${_followUpDate!.month}-${_followUpDate!.day}'
                      : '可选填',
                  style: TextStyle(
                    fontSize: 16,
                    color: _followUpDate != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '病历照片',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.camera,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '添加',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photos.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '暂无照片',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photos.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(entry.value),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _photos.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}
