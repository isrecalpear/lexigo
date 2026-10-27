// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_generated.dart';

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
  String get newWordHintEasterEgg => '❤️ ;D';

  @override
  String get settingsFont => '字体';

  @override
  String get fontPickerTitle => '选择字体';

  @override
  String get fontSystem => '系统字体';

  @override
  String get fontSystemSubtitle => '跟随操作系统默认字体，不额外下载';

  @override
  String get fontMiSans => 'MiSans';

  @override
  String get fontMiSansSubtitle => '小米官方字体，从 hyperos.mi.com 下载';

  @override
  String get fontHarmonyOS => 'HarmonyOS Sans';

  @override
  String get fontHarmonyOSSubtitle => '华为官方字体，从 developer.huawei.com 下载';

  @override
  String get fontDownloadTitle => '下载字体';

  @override
  String fontDownloadConfirm(Object font, Object size) {
    return '「$font」不随应用分发，需要从字体官方网站下载（约 $size MB，需联网）。是否继续？';
  }

  @override
  String get fontOfficialSource => '官方来源';

  @override
  String get fontLicenseHint => '字体版权归字体厂商所有，仅用于本机界面显示。';

  @override
  String get fontDownloadPreparing => '正在准备下载…';

  @override
  String fontDownloading(Object percent, Object received, Object total) {
    return '正在下载字体包… $percent%（$received MB / $total MB）';
  }

  @override
  String fontDownloadingUnknown(Object received) {
    return '正在下载字体包… 已下载 $received MB';
  }

  @override
  String fontDownloadFailed(Object error) {
    return '字体下载失败: $error';
  }

  @override
  String fontApplied(Object font) {
    return '已应用 $font';
  }

  @override
  String get fontNotAvailable => '字体包不完整，请重新下载。';

  @override
  String get importPreviewTitle => '确认导入';

  @override
  String importPreviewSummary(Object total, Object count, Object skipped) {
    return '共 $total 行：可导入 $count 条，跳过 $skipped 条（空行或重复）。';
  }

  @override
  String get importInProgress => '正在导入…';

  @override
  String get importNothingToImport => '没有可导入的新单词';

  @override
  String get today => '今天';

  @override
  String get recordsEmptyDay => '当天没有学习记录';

  @override
  String recordsReviewCount(Object count) {
    return '复习 $count 次';
  }

  @override
  String recordsWordCount(Object count) {
    return '涉及 $count 词';
  }

  @override
  String recordsForgottenCount(Object count) {
    return '未记住 $count 个';
  }

  @override
  String recordsAverageTime(Object seconds) {
    return '平均 $seconds 秒/词';
  }

  @override
  String get recordsDueLabel => '到期复习';

  @override
  String get recordsOverdueLabel => '积压';

  @override
  String get recordsNewWordsLabel => '待学新词';

  @override
  String get recordsPreviousWeek => '上一周';

  @override
  String get recordsNextWeek => '下一周';

  @override
  String get recordsJumpToWeek => '选择日期跳转到所在周';

  @override
  String get recordsBackToToday => '回到今天';

  @override
  String get recordsForecastHint => '未来日期为基于当前排程的预测。';

  @override
  String get recordsDueListTitle => '预计到期单词';

  @override
  String get recordsNoDue => '当天没有到期单词';

  @override
  String get recordsOverview => '学习概览';

  @override
  String get recordsStreakLabel => '连续学习';

  @override
  String get recordsLast7Days => '近 7 天复习';

  @override
  String get recordsRetentionLabel => '记忆保持率';

  @override
  String get recordsMasteredLabel => '已掌握';

  @override
  String get recordsVocabularyLabel => '词库';

  @override
  String get recordsTotalReviewsLabel => '累计复习';

  @override
  String get recordsRetry => '重试';

  @override
  String get recordsLoadFailed => '记录加载失败';

  @override
  String get recordsUnavailable => '记录不可用';

  @override
  String get difficultyLabel => '记忆难度';

  @override
  String get stabilityLabel => '记忆强度';

  @override
  String daysLabel(Object value) {
    return '$value 天';
  }

  @override
  String get nextReviewLabel => '下次复习';

  @override
  String get lastReviewLabel => '上次复习';

  @override
  String get forgettingCurve => '遗忘曲线';

  @override
  String currentRetrievability(Object percent) {
    return '当前记忆概率 $percent%';
  }

  @override
  String get neverReviewed => '尚未复习';

  @override
  String get cardHistoryTitle => '复习记录';

  @override
  String get noCardHistory => '暂无复习记录';

  @override
  String get searchHint => '搜索单词';

  @override
  String get showAnswer => '显示答案';

  @override
  String get hideAnswer => '隐藏答案';

  @override
  String get languageEnglishName => '英语';

  @override
  String get languageKoreanName => '韩语';

  @override
  String get languageRussianName => '俄语';

  @override
  String get sectionStudy => '学习';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionData => '数据';

  @override
  String get sectionSettings => '设置';

  @override
  String get sectionAbout => '关于';

  @override
  String get sectionWords => '单词';

  @override
  String get sectionImportExport => '导入与导出';

  @override
  String get ratingPrompt => '你记得怎么样？';

  @override
  String get wordListEmptyHint => '导入单词清单或手动添加单词，开始学习。';

  @override
  String get summaryLearned => '已学习';

  @override
  String get summaryReviewed => '已复习';

  @override
  String get summaryToReview => '待复习';

  @override
  String get swipeHint => '左滑或点击「下一个」换一个单词';

  @override
  String get recordsLast7DaysShort => '近 7 天复习';
}
