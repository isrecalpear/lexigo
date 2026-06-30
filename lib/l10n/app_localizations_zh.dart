// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '背了么 - LexiGo';

  @override
  String get tabStudy => '背';

  @override
  String get tabRecords => '记录';

  @override
  String get tabMe => '我的';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get startPrompt => '你认识吗？';

  @override
  String get next => '下一个';

  @override
  String get startLearning => '开始学习';

  @override
  String get learningTitle => '学习';

  @override
  String get ratingEasy => '简单';

  @override
  String get ratingGood => '还行';

  @override
  String get ratingHard => '困难';

  @override
  String get ratingAgain => '忘记';

  @override
  String get settingsWordManagement => '单词管理';

  @override
  String get settingsWordManagementSubtitle => '查看与维护单词数据';

  @override
  String get settingsEditSettings => '编辑设置';

  @override
  String get settingsEditSettingsSubtitle => '编辑应用设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeColor => '主题色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeColorAuto => '自动';

  @override
  String get themeColorPick => '选择颜色';

  @override
  String get themeColorPickerTitle => '选择主题色';

  @override
  String get themeColorHue => '色相';

  @override
  String get themeColorSaturation => '饱和度';

  @override
  String get themeColorBrightness => '亮度';

  @override
  String get themeColorHexLabel => '十六进制颜色';

  @override
  String get themeColorHexHint => '#RRGGBB 或 #AARRGGBB';

  @override
  String get themeColorHexInvalid => '无效的颜色值';

  @override
  String get settingsLogManagement => '日志管理';

  @override
  String get settingsLogManagementSubtitle => '查看和管理应用日志';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutSubtitle => '背了么 - LexiGo';

  @override
  String get wordManagementTitle => '单词管理';

  @override
  String get wordListTitle => '查看单词';

  @override
  String get wordListSubtitle => '查看单词清单';

  @override
  String get importWordListTitle => '导入单词清单';

  @override
  String get importWordListSubtitle => '从外部文件导入单词清单';

  @override
  String get exportWordListTitle => '导出单词清单';

  @override
  String get exportWordListSubtitle => '将单词清单导出到外部文件';

  @override
  String get exportFailedNoFolder => '导出失败！未找到下载文件夹';

  @override
  String get exportFailedUserDismiss => '导出失败！用户取消操作';

  @override
  String get exportFailedUnavailable => '导出失败！不支持的操作';

  @override
  String exportSuccess(Object filePath) {
    return '导出成功，文件在 $filePath';
  }

  @override
  String exportFailed(Object error) {
    return '导出失败: $error';
  }

  @override
  String get addWordTitle => '添加单词';

  @override
  String get addWordSubtitle => '手动添加单词到数据库';

  @override
  String get selectLanguageTitle => '选择语言';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String importSuccess(Object count, Object skipped) {
    return '导入成功: $count 条，跳过: $skipped 条';
  }

  @override
  String importFailed(Object error) {
    return '导入失败: $error';
  }

  @override
  String get addWordPageTitle => '添加单词';

  @override
  String get editWordPageTitle => '编辑单词';

  @override
  String get fieldLanguage => '语言';

  @override
  String get fieldOriginal => '原文';

  @override
  String get fieldTranslation => '翻译';

  @override
  String get fieldOriginalExample => '原文例句';

  @override
  String get fieldExampleTranslation => '例句翻译';

  @override
  String get fieldUnitId => '单元ID';

  @override
  String get fieldBookId => '书籍ID';

  @override
  String get save => '保存';

  @override
  String get required => '必填';

  @override
  String get addSuccess => '添加成功';

  @override
  String addFailed(Object error) {
    return '添加失败: $error';
  }

  @override
  String get editSuccess => '修改成功';

  @override
  String editFailed(Object error) {
    return '修改失败: $error';
  }

  @override
  String get logManagementTitle => '日志管理';

  @override
  String get logClearConfirmTitle => '确认清除';

  @override
  String get logClearConfirmContent => '确定要清除所有日志吗？此操作不可恢复。';

  @override
  String get logCleared => '日志已清除';

  @override
  String clearFailed(Object error) {
    return '清除失败: $error';
  }

  @override
  String get logSizeTitle => '日志大小';

  @override
  String get logViewTitle => '日志查看';

  @override
  String get logViewSubtitle => '查看最新日志';

  @override
  String get logPathNotFound => '未找到日志路径';

  @override
  String get logEmpty => '暂无日志';

  @override
  String logReadFailed(Object error) {
    return '读取日志失败: $error';
  }

  @override
  String get logShareNotSupported => 'Linux 系统不支持分享日志';

  @override
  String get logFileNotFound => '未找到日志文件';

  @override
  String get logShareSuccess => '日志分享成功';

  @override
  String logShareFailed(Object error) {
    return '分享日志失败: $error';
  }

  @override
  String get logAboutTitle => '关于日志';

  @override
  String get logAboutSubtitle => '日志文件保存在应用数据目录，最多保留7天，超过后自动删除旧日志。';

  @override
  String get refreshInfo => '刷新信息';

  @override
  String get clearLogs => '清除日志';

  @override
  String get recordsBuilding => '开发中...';

  @override
  String get wordViewTitle => '单词清单';

  @override
  String get wordViewEmpty => '暂无单词';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get deleteWordTitle => '删除单词';

  @override
  String deleteWordConfirm(Object word) {
    return '确定删除 $word 吗？';
  }

  @override
  String get deleteSuccess => '删除成功';

  @override
  String deleteFailed(Object error) {
    return '删除失败: $error';
  }

  @override
  String loadFailed(Object error) {
    return '加载失败: $error';
  }

  @override
  String get familiarityLearning => '生疏';

  @override
  String get familiarityRelearning => '不熟';

  @override
  String get familiarityReview => '熟悉';

  @override
  String get wordCardCorrect => '纠错';

  @override
  String get wordCardMarkKnown => '标记为熟知';

  @override
  String get wordCardMarkKnownTitle => '标记为熟知？';

  @override
  String wordCardMarkKnownConfirm(Object word) {
    return '确认将 \"$word\" 标记为熟知。';
  }

  @override
  String learningSummary(Object learned, Object reviewed, Object toReview) {
    return '已学 $learned 个，复习 $reviewed 个，还剩 $toReview 个';
  }

  @override
  String get learningSummaryTitle => '总结';

  @override
  String get learningSummaryNextLabel => '接下来的是：';

  @override
  String get learningSummaryEnd => '结束学习';

  @override
  String get learningSummaryNextGroup => '下一组单词';

  @override
  String get newWordHint => '这是一个未学习过的新单词';

  @override
  String get newWordHintEasterEgg => '❤️';
}
