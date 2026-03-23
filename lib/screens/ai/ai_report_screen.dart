import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class AIReportScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const AIReportScreen({super.key, required this.pet});

  @override
  ConsumerState<AIReportScreen> createState() => _AIReportScreenState();
}

class _AIReportScreenState extends ConsumerState<AIReportScreen> {
  bool _isGenerating = false;
  String? _report;

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
        title: const Text(
          'AI健康报告',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_report != null)
            IconButton(
              icon: const Icon(CupertinoIcons.share, color: AppColors.primary),
              onPressed: _shareReport,
            ),
        ],
      ),
      body: _isGenerating
          ? _buildLoadingState()
          : _report == null
              ? _buildGenerateState()
              : _buildReportView(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CupertinoActivityIndicator(
              radius: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI正在分析健康数据...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请稍候，正在生成${widget.pet.name}的专属报告',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateState() {
    final vaccineRecords = ref.watch(vaccineRecordsProvider(widget.pet.id));
    final dewormRecords = ref.watch(dewormRecordsProvider(widget.pet.id));
    final medicalRecords = ref.watch(medicalRecordsProvider(widget.pet.id));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                CupertinoIcons.chart_bar,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI健康分析报告',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '基于${widget.pet.name}的以下数据生成专业报告：',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildDataBadge(CupertinoIcons.eyedropper, '${vaccineRecords.length}条疫苗'),
                _buildDataBadge(CupertinoIcons.bandage, '${dewormRecords.length}条驱虫'),
                _buildDataBadge(CupertinoIcons.heart, '${medicalRecords.length}条就诊'),
              ],
            ),
            const SizedBox(height: 32),
            IOSButton(
              text: '生成报告',
              icon: CupertinoIcons.wand_stars,
              onPressed: _generateReport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppStyles.padding),
            padding: const EdgeInsets.all(AppStyles.padding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF7AB57A)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.pet.name}的健康报告',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '生成时间：${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    _report!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppStyles.padding),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyReport,
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 18),
                  label: const Text('复制'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: const Icon(CupertinoIcons.refresh, size: 18),
                  label: const Text('重新生成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _report = null;
    });

    final vaccineRecords = ref.read(vaccineRecordsProvider(widget.pet.id));
    final dewormRecords = ref.read(dewormRecordsProvider(widget.pet.id));
    final medicalRecords = ref.read(medicalRecordsProvider(widget.pet.id));

    final aiService = ref.read(aiServiceProvider);

    final report = await aiService.generateHealthReport(
      petInfo: {
        'name': widget.pet.name,
        'species': widget.pet.species,
        'breed': widget.pet.breed,
        'age': widget.pet.age,
        'weight': widget.pet.weight,
        'gender': widget.pet.gender,
      },
      vaccineRecords: vaccineRecords.map((r) => r.toJson()).toList(),
      dewormRecords: dewormRecords.map((r) => r.toJson()).toList(),
      medicalRecords: medicalRecords.map((r) => r.toJson()).toList(),
    );

    setState(() {
      _isGenerating = false;
      _report = report;
    });
  }

  void _copyReport() {
    if (_report != null) {
      Clipboard.setData(ClipboardData(text: _report!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('报告已复制到剪贴板'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _shareReport() {
    // 实现分享功能
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '分享报告',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(CupertinoIcons.chat_bubble),
              title: const Text('发送给微信好友'),
              onTap: () {
                Navigator.pop(context);
                _copyReport();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.doc_text),
              title: const Text('复制报告内容'),
              onTap: () {
                Navigator.pop(context);
                _copyReport();
              },
            ),
          ],
        ),
      ),
    );
  }
}
