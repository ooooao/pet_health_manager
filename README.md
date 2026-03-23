# 宠康管家 - 宠物健康管理App

一款轻量级的宠物健康管理工具，支持宠物档案建档、疫苗/驱虫/就诊记录留存，AI自动生成健康报告。

## 功能特性

### 核心功能
- **宠物档案管理**：支持多宠物绑定，记录名字、品种、性别、生日、体重、毛色、芯片编号、头像
- **健康记录**：
  - 疫苗记录（类型、接种日期、医院、有效期、自动计算下次接种时间）
  - 驱虫记录（体内/体外/内外同驱、药品名称、日期、自动提醒）
  - 就诊记录（日期、医院、症状、诊断、处方、费用、病历照片）
- **AI健康报告**：基于本地数据生成专业健康报告（支持离线生成）
- **提醒中心**：疫苗/驱虫/复诊/自定义提醒，逾期事项高亮显示

### 技术特点
- 本地离线存储（Hive），无需服务器
- 跨平台：一套代码支持iOS/Android
- iOS风格界面设计
- 状态管理：Riverpod

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── pet.dart                 # 宠物模型
│   ├── vaccine_record.dart      # 疫苗记录
│   ├── deworm_record.dart       # 驱虫记录
│   ├── medical_record.dart      # 就诊记录
│   └── reminder.dart            # 提醒模型
├── services/                    # 业务服务
│   ├── database_service.dart    # 数据库服务
│   ├── ai_service.dart          # AI报告生成
│   └── notification_service.dart # 本地通知
├── providers/                   # 状态管理
│   └── app_providers.dart
├── screens/                     # 页面
│   ├── home/                    # 首页
│   ├── pet/                     # 宠物详情/编辑
│   ├── records/                 # 健康记录
│   ├── ai/                      # AI报告
│   ├── reminders/               # 提醒中心
│   └── settings/                # 设置
└── widgets/                     # 公共组件
    └── common_widgets.dart
```

## 运行环境

- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code

## 如何运行

### 1. 安装Flutter
确保已安装Flutter SDK并配置环境变量：
```bash
flutter doctor
```

### 2. 安装依赖
```bash
cd C:\pet_health_manager
flutter pub get
```

### 3. 运行应用

**Android调试：**
```bash
flutter run
```

**iOS调试（需要Mac）：**
```bash
flutter run -d ios
```

## 打包发布

### Android APK
```bash
flutter build apk --release
```
APK文件位置：`build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
注意：iOS打包需要在Mac上进行。

## 后续开发计划

- [ ] 数据云同步
- [ ] 体重趋势图表
- [ ] 宠物养护百科
- [ ] PDF健康档案导出
- [ ] 暗黑模式
- [ ] 多语言支持

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter | 跨平台UI框架 |
| Hive | 本地数据存储 |
| Riverpod | 状态管理 |
| Dio | 网络请求 |
| flutter_local_notifications | 本地通知 |
| image_picker | 图片选择 |

## 注意事项

1. **iOS打包**：Windows无法直接打包iOS，需要租用云Mac或在Mac上运行
2. **API密钥**：如需使用AI报告功能，可在设置中配置AI API密钥
3. **数据备份**：建议定期导出数据备份

## 开发团队

使用Claude Code辅助开发，基于Flutter跨平台框架。

## License

MIT License
