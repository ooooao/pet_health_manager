import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class PetEditScreen extends ConsumerStatefulWidget {
  final Pet? pet;

  const PetEditScreen({super.key, this.pet});

  @override
  ConsumerState<PetEditScreen> createState() => _PetEditScreenState();
}

class _PetEditScreenState extends ConsumerState<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _chipController = TextEditingController();

  String _species = '猫';
  String _gender = '公';
  DateTime _birthday = DateTime.now().subtract(const Duration(days: 365));
  String? _avatarPath;

  final List<String> _speciesList = ['猫', '狗', '兔子', '仓鼠', '鸟类', '其他'];
  final List<String> _genderList = ['公', '母'];

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _weightController.text = widget.pet!.weight.toString();
      _colorController.text = widget.pet!.color;
      _chipController.text = widget.pet!.chipNumber ?? '';
      _species = widget.pet!.species;
      _gender = widget.pet!.gender;
      _birthday = widget.pet!.birthday;
      _avatarPath = widget.pet!.avatarPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _chipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final pet = Pet(
      id: widget.pet?.id,
      name: _nameController.text.trim(),
      species: _species,
      breed: _breedController.text.trim(),
      gender: _gender,
      birthday: _birthday,
      weight: double.tryParse(_weightController.text) ?? 0,
      color: _colorController.text.trim(),
      chipNumber: _chipController.text.trim().isEmpty ? null : _chipController.text.trim(),
      avatarPath: _avatarPath,
      createdAt: widget.pet?.createdAt,
    );

    if (widget.pet == null) {
      await ref.read(petsProvider.notifier).addPet(pet);
      // 设置新添加的宠物为选中
      ref.read(selectedPetProvider.notifier).state = pet;
    } else {
      await ref.read(petsProvider.notifier).updatePet(pet);
      if (ref.read(selectedPetProvider)?.id == pet.id) {
        ref.read(selectedPetProvider.notifier).state = pet;
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

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
          isEditing ? '编辑宠物' : '添加宠物',
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
            _buildAvatarSection(),
            const SizedBox(height: 24),
            IOSInputField(
              label: '宠物名字 *',
              hint: '请输入宠物名字',
              controller: _nameController,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入宠物名字';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildSpeciesSelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '品种 *',
              hint: '如：英短、金毛等',
              controller: _breedController,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入品种';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildGenderSelector(),
            const SizedBox(height: 20),
            _buildBirthdaySelector(),
            const SizedBox(height: 20),
            IOSInputField(
              label: '体重 (kg) *',
              hint: '请输入体重',
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) {
                  return '请输入体重';
                }
                if (double.tryParse(v!) == null) {
                  return '请输入有效的数字';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '毛色',
              hint: '如：白色、黑色、花色等',
              controller: _colorController,
            ),
            const SizedBox(height: 20),
            IOSInputField(
              label: '芯片编号',
              hint: '可选填',
              controller: _chipController,
            ),
            if (isEditing) ...[
              const SizedBox(height: 32),
              IOSButton(
                text: '删除宠物',
                isPrimary: false,
                onPressed: _deletePet,
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          ),
          child: _avatarPath != null
              ? ClipOval(
                  child: Image.file(
                    File(_avatarPath!),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.camera,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '上传头像',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSpeciesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '宠物类型',
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
          children: _speciesList.map((species) {
            final isSelected = _species == species;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _species = species;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  species,
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

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _genderList.map((gender) {
            final isSelected = _gender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _gender = gender;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: gender == '公' ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gender,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBirthdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '生日',
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
                Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_birthday.year}年${_birthday.month}月${_birthday.day}日',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '(${DateTime.now().difference(_birthday).inDays ~/ 365}岁)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _deletePet() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后所有相关记录都将被清除，此操作不可恢复'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () async {
              await ref.read(petsProvider.notifier).deletePet(widget.pet!.id);
              if (ref.read(selectedPetProvider)?.id == widget.pet!.id) {
                ref.read(selectedPetProvider.notifier).state = null;
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
