import 'dart:convert';
import 'package:dio/dio.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Dio _dio = Dio();

  // API配置 - 使用免费的通义千问或豆包API
  // 请替换为你的API密钥
  String _apiKey = '';
  String _apiUrl = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation';

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // 生成宠物健康报告
  Future<String> generateHealthReport({
    required Map<String, dynamic> petInfo,
    required List<Map<String, dynamic>> vaccineRecords,
    required List<Map<String, dynamic>> dewormRecords,
    required List<Map<String, dynamic>> medicalRecords,
  }) async {
    if (_apiKey.isEmpty) {
      return _generateLocalReport(
        petInfo: petInfo,
        vaccineRecords: vaccineRecords,
        dewormRecords: dewormRecords,
        medicalRecords: medicalRecords,
      );
    }

    try {
      final prompt = _buildPrompt(
        petInfo: petInfo,
        vaccineRecords: vaccineRecords,
        dewormRecords: dewormRecords,
        medicalRecords: medicalRecords,
      );

      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'qwen-turbo',
          'input': {
            'messages': [
              {
                'role': 'system',
                'content': '你是一位专业的宠物健康顾问，擅长分析宠物健康数据并给出专业建议。'
              },
              {
                'role': 'user',
                'content': prompt,
              }
            ],
          },
        },
      );

      if (response.statusCode == 200) {
        return response.data['output']['text'] ?? '生成报告失败';
      } else {
        return 'API调用失败: ${response.statusMessage}';
      }
    } catch (e) {
      // API调用失败时返回本地生成的报告
      return _generateLocalReport(
        petInfo: petInfo,
        vaccineRecords: vaccineRecords,
        dewormRecords: dewormRecords,
        medicalRecords: medicalRecords,
      );
    }
  }

  // 构建Prompt
  String _buildPrompt({
    required Map<String, dynamic> petInfo,
    required List<Map<String, dynamic>> vaccineRecords,
    required List<Map<String, dynamic>> dewormRecords,
    required List<Map<String, dynamic>> medicalRecords,
  }) {
    return '''
请根据以下宠物信息和健康记录，生成一份专业、简洁的宠物健康报告，包含：
1. 健康概况
2. 疫苗驱虫完成情况
3. 病史分析
4. 养护建议
5. 风险预警

语言通俗易懂，适合宠主阅读。

宠物信息：
${jsonEncode(petInfo)}

疫苗记录：
${jsonEncode(vaccineRecords)}

驱虫记录：
${jsonEncode(dewormRecords)}

就诊记录：
${jsonEncode(medicalRecords)}
'''
;
  }

  // 本地生成报告（无需API）
  String _generateLocalReport({
    required Map<String, dynamic> petInfo,
    required List<Map<String, dynamic>> vaccineRecords,
    required List<Map<String, dynamic>> dewormRecords,
    required List<Map<String, dynamic>> medicalRecords,
  }) {
    final petName = petInfo['name'] ?? '宠物';
    final species = petInfo['species'] ?? '未知';
    final age = petInfo['age'] ?? '未知';
    final weight = petInfo['weight'] ?? '未知';

    // 分析疫苗状态
    int completedVaccines = vaccineRecords.length;
    int overdueVaccines = vaccineRecords.where((v) {
      final nextDate = DateTime.tryParse(v['nextVaccinationDate'] ?? '');
      if (nextDate == null) return false;
      return nextDate.isBefore(DateTime.now());
    }).length;

    // 分析驱虫状态
    int completedDeworms = dewormRecords.length;
    int overdueDeworms = dewormRecords.where((d) {
      final nextDate = DateTime.tryParse(d['nextDewormDate'] ?? '');
      if (nextDate == null) return false;
      return nextDate.isBefore(DateTime.now());
    }).length;

    // 分析就诊次数
    int medicalCount = medicalRecords.length;

    // 生成报告
    StringBuffer report = StringBuffer();

    report.writeln('🐾 $petName 的健康报告');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln();

    // 健康概况
    report.writeln('📋 健康概况');
    report.writeln('• 宠物名称：$petName');
    report.writeln('• 品种：$species');
    report.writeln('• 年龄：$age');
    report.writeln('• 体重：${weight}kg');
    report.writeln();

    // 疫苗驱虫完成情况
    report.writeln('💉 疫苗驱虫完成情况');
    report.writeln('• 已完成疫苗接种：$completedVaccines 次');
    if (overdueVaccines > 0) {
      report.writeln('⚠️ 注意：有 $overdueVaccines 项疫苗已过期，请及时补种');
    } else {
      report.writeln('✅ 疫苗接种状态正常');
    }
    report.writeln('• 已完成驱虫：$completedDeworms 次');
    if (overdueDeworms > 0) {
      report.writeln('⚠️ 注意：有 $overdueDeworms 项驱虫已过期，请及时处理');
    } else {
      report.writeln('✅ 驱虫状态正常');
    }
    report.writeln();

    // 病史分析
    report.writeln('🏥 病史分析');
    if (medicalCount == 0) {
      report.writeln('✅ 暂无就诊记录，保持健康状态！');
    } else {
      report.writeln('• 历史就诊次数：$medicalCount 次');
      report.writeln('• 建议定期体检，关注健康状况');
    }
    report.writeln();

    // 养护建议
    report.writeln('💡 养护建议');
    if (species.contains('猫')) {
      report.writeln('• 建议每年接种猫三联和狂犬疫苗');
      report.writeln('• 室内猫每3个月驱虫一次，外出猫每月驱虫');
      report.writeln('• 提供充足的饮水和优质猫粮');
      report.writeln('• 定期梳理毛发，预防毛球症');
    } else if (species.contains('狗')) {
      report.writeln('• 建议每年接种犬八联和狂犬疫苗');
      report.writeln('• 每月进行一次体内外驱虫');
      report.writeln('• 每天保证适量运动，维持健康体重');
      report.writeln('• 定期刷牙，预防口腔疾病');
    }
    report.writeln('• 保持生活环境清洁，定期消毒');
    report.writeln('• 观察宠物日常行为和食欲变化');
    report.writeln();

    // 风险预警
    report.writeln('⚠️ 风险预警');
    List<String> warnings = [];
    if (overdueVaccines > 0) warnings.add('疫苗已过期，请及时补种');
    if (overdueDeworms > 0) warnings.add('驱虫已过期，请及时处理');
    if (medicalCount > 3) warnings.add('近期就诊频繁，建议全面体检');

    if (warnings.isEmpty) {
      report.writeln('✅ 当前无重大健康风险，请继续保持！');
    } else {
      for (var warning in warnings) {
        report.writeln('• $warning');
      }
    }
    report.writeln();

    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    report.writeln('📝 注：本报告基于本地数据生成，仅供参考。如有异常请及时就医。');

    return report.toString();
  }
}
