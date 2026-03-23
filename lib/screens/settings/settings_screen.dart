import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          '设置',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppStyles.padding),
        children: [
          _buildSectionTitle('数据管理'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: CupertinoIcons.arrow_up_doc,
              title: '导出数据',
              subtitle: '将数据导出为JSON文件',
              onTap: () => _exportData(context, ref),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingsItem(
              icon: CupertinoIcons.arrow_down_doc,
              title: '导入数据',
              subtitle: '从JSON文件恢复数据',
              onTap: () => _showComingSoon(context),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingsItem(
              icon: CupertinoIcons.trash,
              title: '清除所有数据',
              subtitle: '删除所有宠物和记录',
              isDestructive: true,
              onTap: () => _clearAllData(context, ref),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('关于'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: CupertinoIcons.info_circle,
              title: '版本',
              subtitle: '1.0.0',
              showArrow: false,
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingsItem(
              icon: CupertinoIcons.heart,
              title: '关于宠康管家',
              subtitle: '轻量化宠物健康管理工具',
              onTap: () => _showAbout(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showArrow = true,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                CupertinoIcons.chevron_right,
                color: AppColors.textHint,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseServiceProvider);

      // 收集所有数据
      final data = {
        'pets': db.getAllPets().map((p) => p.toJson()).toList(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      // 保存到文件
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pet_health_backup.json');
      await file.writeAsString(data.toString());

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '宠康管家数据备份',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('数据导出成功'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _clearAllData(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有宠物档案和健康记录，且不可恢复。确定要继续吗？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('清除'),
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              final pets = db.getAllPets();
              for (var pet in pets) {
                await db.deletePet(pet.id);
              }
              ref.read(selectedPetProvider.notifier).state = null;
              ref.read(petsProvider.notifier).loadPets();

              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('所有数据已清除'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('即将上线'),
        content: const Text('此功能正在开发中，敬请期待'),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF7AB57A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '宠康管家',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '轻量化宠物健康管理工具',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '本应用帮助您：\n\n'
                '• 管理多宠物健康档案\n'
                '• 记录疫苗、驱虫、就诊信息\n'
                '• 自动提醒到期事项\n'
                '• 生成AI健康分析报告\n\n'
                '祝您的宠物健康快乐！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              IOSButton(
                text: '知道了',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
