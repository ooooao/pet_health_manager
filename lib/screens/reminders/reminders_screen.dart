import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../pet/pet_detail_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(allPendingRemindersProvider);
    final overdueReminders = ref.read(databaseServiceProvider).getOverdueReminders();
    final upcomingReminders = ref.read(databaseServiceProvider).getUpcomingReminders(days: 30);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '提醒中心',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: '全部'),
              Tab(text: '即将到期'),
              Tab(text: '已逾期'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReminderList(context, ref, allReminders),
            _buildReminderList(context, ref, upcomingReminders),
            _buildReminderList(context, ref, overdueReminders),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _addCustomReminder(context, ref),
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReminderList(BuildContext context, WidgetRef ref, List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.bell,
        title: '暂无提醒',
        subtitle: '添加提醒，不再错过重要事项',
      );
    }

    // 按状态排序：逾期 > 今天 > 即将到期
    reminders.sort((a, b) => a.status.compareTo(b.status));

    return ListView.builder(
      padding: const EdgeInsets.all(AppStyles.padding),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(context, ref, reminder);
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, Reminder reminder) {
    final pet = ref.read(databaseServiceProvider).getPet(reminder.petId);

    Color statusColor;
    switch (reminder.status) {
      case 0:
        statusColor = AppColors.error;
        break;
      case 1:
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.success;
    }

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(CupertinoIcons.trash, color: Colors.white),
            SizedBox(width: 8),
            Text('删除', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onDismissed: (_) {
        ref.read(remindersProvider(reminder.petId).notifier).deleteReminder(reminder.id);
      },
      child: GestureDetector(
        onTap: () => _toggleComplete(context, ref, reminder),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: reminder.isCompleted ? AppColors.background : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: reminder.isCompleted
                  ? Colors.transparent
                  : statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _toggleComplete(context, ref, reminder),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: reminder.isCompleted
                        ? AppColors.success
                        : statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: reminder.isCompleted
                      ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 16)
                      : Icon(
                          _getReminderIcon(reminder.type),
                          color: statusColor,
                          size: 14,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: reminder.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet?.name ?? ''} · ${reminder.typeText}',
                      style: TextStyle(
                        fontSize: 13,
                        color: reminder.isCompleted
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reminder.reminderDate.month}-${reminder.reminderDate.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: reminder.isCompleted
                          ? AppColors.textHint
                          : statusColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getReminderText(reminder),
                    style: TextStyle(
                      fontSize: 11,
                      color: reminder.isCompleted
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  String _getReminderText(Reminder reminder) {
    if (reminder.isCompleted) return '已完成';
    switch (reminder.status) {
      case 0:
        return '已逾期';
      case 1:
        return '今天';
      case 2:
        final days = reminder.reminderDate.difference(DateTime.now()).inDays;
        return '$days天后';
      default:
        return '未来';
    }
  }

  void _toggleComplete(BuildContext context, WidgetRef ref, Reminder reminder) {
    ref.read(remindersProvider(reminder.petId).notifier).toggleComplete(reminder.id);

    if (!reminder.isCompleted && reminder.isRecurring && reminder.recurringDays != null) {
      // 创建下一次提醒
      final nextReminder = Reminder(
        petId: reminder.petId,
        title: reminder.title,
        type: reminder.type,
        reminderDate: reminder.reminderDate.add(Duration(days: reminder.recurringDays!)),
        isRecurring: true,
        recurringDays: reminder.recurringDays,
        notes: reminder.notes,
      );
      ref.read(remindersProvider(reminder.petId).notifier).addReminder(nextReminder);
    }
  }

  void _addCustomReminder(BuildContext context, WidgetRef ref) {
    final pets = ref.read(petsProvider);
    if (pets.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('无法添加提醒'),
          content: const Text('请先添加宠物档案'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomReminderScreen(),
      ),
    );
  }
}

// 自定义提醒页面
class CustomReminderScreen extends ConsumerStatefulWidget {
  const CustomReminderScreen({super.key});

  @override
  ConsumerState<CustomReminderScreen> createState() => _CustomReminderScreenState();
}

class _CustomReminderScreenState extends ConsumerState<CustomReminderScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  Pet? _selectedPet;
  String _type = Reminder.typeCustom;
  DateTime _reminderDate = DateTime.now().add(const Duration(days: 1));

  final List<Map<String, dynamic>> _types = [
    {'value': Reminder.typeBath, 'label': '洗澡', 'icon': CupertinoIcons.drop},
    {'value': Reminder.typeNail, 'label': '剪指甲', 'icon': CupertinoIcons.scissors},
    {'value': Reminder.typeFeed, 'label': '喂食', 'icon': CupertinoIcons.clock},
    {'value': Reminder.typeCustom, 'label': '自定义', 'icon': CupertinoIcons.bell},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择宠物')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提醒标题')),
      );
      return;
    }

    final reminder = Reminder(
      petId: _selectedPet!.id,
      title: _titleController.text.trim(),
      type: _type,
      reminderDate: _reminderDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await ref.read(remindersProvider(_selectedPet!.id).notifier).addReminder(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '添加提醒',
          style: TextStyle(
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
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.padding),
        children: [
          _buildPetSelector(pets),
          const SizedBox(height: 20),
          _buildTypeSelector(),
          const SizedBox(height: 20),
          IOSInputField(
            label: '提醒标题 *',
            hint: '如：给猫咪洗澡',
            controller: _titleController,
          ),
          const SizedBox(height: 20),
          _buildDateSelector(),
          const SizedBox(height: 20),
          IOSInputField(
            label: '备注',
            hint: '可选填',
            controller: _notesController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector(List<Pet> pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择宠物',
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
          children: pets.map((pet) {
            final isSelected = _selectedPet?.id == pet.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPet = pet;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pet.name,
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

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '提醒类型',
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
          children: _types.map((type) {
            final isSelected = _type == type['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _type = type['value'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'],
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
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
          '提醒日期',
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
                  '${_reminderDate.year}-${_reminderDate.month}-${_reminderDate.day}',
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
}
