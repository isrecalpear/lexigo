/// Application localization strings for multi-language support.
///
/// Supports English and Chinese with a fallback to English.
/// See _localizedValues map at the bottom for all translated strings.
library;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Provides localized strings for the current locale.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  /// Supported locales (English and Chinese).
  static const supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// Gets the AppLocalizations instance from context.
  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'No AppLocalizations found in context');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Retrieves a translated string by key with optional parameter substitution.
  String _t(String key, [Map<String, String>? params]) {
    final languageCode = locale.languageCode;
    final value =
        _localizedValues[languageCode]?[key] ?? _localizedValues['en']![key]!;
    if (params == null || params.isEmpty) {
      return value;
    }
    var result = value;
    params.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue);
    });
    return result;
  }

  String get appTitle => _t('appTitle');
  String get tabStudy => _t('tabStudy');
  String get tabRecords => _t('tabRecords');
  String get tabMe => _t('tabMe');
  String get language => _t('language');
  String get languageSystem => _t('languageSystem');
  String get languageChinese => _t('languageChinese');
  String get languageEnglish => _t('languageEnglish');
  String get startPrompt => _t('startPrompt');
  String get next => _t('next');
  String get startLearning => _t('startLearning');
  String get learningTitle => _t('learningTitle');
  String get ratingEasy => _t('ratingEasy');
  String get ratingGood => _t('ratingGood');
  String get ratingHard => _t('ratingHard');
  String get ratingAgain => _t('ratingAgain');
  String get settingsWordManagement => _t('settingsWordManagement');
  String get settingsWordManagementSubtitle =>
      _t('settingsWordManagementSubtitle');
  String get settingsEditSettings => _t('settingsEditSettings');
  String get settingsEditSettingsSubtitle => _t('settingsEditSettingsSubtitle');
  String get settingsLanguage => _t('settingsLanguage');
  String get settingsTheme => _t('settingsTheme');
  String get settingsThemeColor => _t('settingsThemeColor');
  String get settingsFont => _t('settingsFont');
  String get fontPickerTitle => _t('fontPickerTitle');
  String get fontSystem => _t('fontSystem');
  String get fontSystemSubtitle => _t('fontSystemSubtitle');
  String get fontMiSans => _t('fontMiSans');
  String get fontMiSansSubtitle => _t('fontMiSansSubtitle');
  String get fontHarmonyOS => _t('fontHarmonyOS');
  String get fontHarmonyOSSubtitle => _t('fontHarmonyOSSubtitle');
  String get fontDownloadTitle => _t('fontDownloadTitle');
  String fontDownloadConfirm(String font, String sizeMb) =>
      _t('fontDownloadConfirm', {'font': font, 'size': sizeMb});
  String get fontOfficialSource => _t('fontOfficialSource');
  String get fontLicenseHint => _t('fontLicenseHint');
  String get fontDownloadPreparing => _t('fontDownloadPreparing');
  String fontDownloading(String percent, String received, String total) => _t(
    'fontDownloading',
    {'percent': percent, 'received': received, 'total': total},
  );
  String fontDownloadingUnknown(String received) =>
      _t('fontDownloadingUnknown', {'received': received});
  String fontDownloadFailed(String error) =>
      _t('fontDownloadFailed', {'error': error});
  String fontApplied(String font) => _t('fontApplied', {'font': font});
  String get fontNotAvailable => _t('fontNotAvailable');
  String get themeSystem => _t('themeSystem');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeColorAuto => _t('themeColorAuto');
  String get themeColorPick => _t('themeColorPick');
  String get themeColorPickerTitle => _t('themeColorPickerTitle');
  String get themeColorHue => _t('themeColorHue');
  String get themeColorSaturation => _t('themeColorSaturation');
  String get themeColorBrightness => _t('themeColorBrightness');
  String get themeColorHexLabel => _t('themeColorHexLabel');
  String get themeColorHexHint => _t('themeColorHexHint');
  String get themeColorHexInvalid => _t('themeColorHexInvalid');
  String get settingsLogManagement => _t('settingsLogManagement');
  String get settingsLogManagementSubtitle =>
      _t('settingsLogManagementSubtitle');
  String get settingsAbout => _t('settingsAbout');
  String get settingsAboutSubtitle => _t('settingsAboutSubtitle');
  String get wordManagementTitle => _t('wordManagementTitle');
  String get wordListTitle => _t('wordListTitle');
  String get wordListSubtitle => _t('wordListSubtitle');
  String get importWordListTitle => _t('importWordListTitle');
  String get importWordListSubtitle => _t('importWordListSubtitle');
  String get exportWordListTitle => _t('exportWordListTitle');
  String get exportWordListSubtitle => _t('exportWordListSubtitle');
  String get addWordTitle => _t('addWordTitle');
  String get addWordSubtitle => _t('addWordSubtitle');
  String get selectLanguageTitle => _t('selectLanguageTitle');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String importSuccess(int count, int skipped) =>
      _t('importSuccess', {'count': '$count', 'skipped': '$skipped'});
  String importFailed(String error) => _t('importFailed', {'error': error});
  String get importPreviewTitle => _t('importPreviewTitle');
  String importPreviewSummary(int total, int count, int skipped) => _t(
    'importPreviewSummary',
    {'total': '$total', 'count': '$count', 'skipped': '$skipped'},
  );
  String get importInProgress => _t('importInProgress');
  String get importNothingToImport => _t('importNothingToImport');
  String get addWordPageTitle => _t('addWordPageTitle');
  String get editWordPageTitle => _t('editWordPageTitle');
  String get fieldLanguage => _t('fieldLanguage');
  String get fieldOriginal => _t('fieldOriginal');
  String get fieldTranslation => _t('fieldTranslation');
  String get fieldOriginalExample => _t('fieldOriginalExample');
  String get fieldExampleTranslation => _t('fieldExampleTranslation');
  String get fieldUnitId => _t('fieldUnitId');
  String get fieldBookId => _t('fieldBookId');
  String get save => _t('save');
  String get required => _t('required');
  String get addSuccess => _t('addSuccess');
  String addFailed(String error) => _t('addFailed', {'error': error});
  String get editSuccess => _t('editSuccess');
  String editFailed(String error) => _t('editFailed', {'error': error});
  String get logManagementTitle => _t('logManagementTitle');
  String get logClearConfirmTitle => _t('logClearConfirmTitle');
  String get logClearConfirmContent => _t('logClearConfirmContent');
  String get logCleared => _t('logCleared');
  String clearFailed(String error) => _t('clearFailed', {'error': error});
  String get logSizeTitle => _t('logSizeTitle');
  String get logViewTitle => _t('logViewTitle');
  String get logViewSubtitle => _t('logViewSubtitle');
  String get logPathNotFound => _t('logPathNotFound');
  String get logEmpty => _t('logEmpty');
  String logReadFailed(String error) => _t('logReadFailed', {'error': error});
  String get logShareNotSupported => _t('logShareNotSupported');
  String get logFileNotFound => _t('logFileNotFound');
  String get logShareSuccess => _t('logShareSuccess');
  String logShareFailed(String error) => _t('logShareFailed', {'error': error});
  String get logAboutTitle => _t('logAboutTitle');
  String get logAboutSubtitle => _t('logAboutSubtitle');
  String get refreshInfo => _t('refreshInfo');
  String get clearLogs => _t('clearLogs');
  String get today => _t('today');
  String get recordsEmptyDay => _t('recordsEmptyDay');
  String recordsReviewCount(int count) =>
      _t('recordsReviewCount', {'count': '$count'});
  String recordsWordCount(int count) =>
      _t('recordsWordCount', {'count': '$count'});
  String recordsForgottenCount(int count) =>
      _t('recordsForgottenCount', {'count': '$count'});
  String recordsAverageTime(int seconds) =>
      _t('recordsAverageTime', {'seconds': '$seconds'});
  String get recordsDueLabel => _t('recordsDueLabel');
  String get recordsOverdueLabel => _t('recordsOverdueLabel');
  String get recordsNewWordsLabel => _t('recordsNewWordsLabel');
  String get recordsPreviousWeek => _t('recordsPreviousWeek');
  String get recordsNextWeek => _t('recordsNextWeek');
  String get recordsJumpToWeek => _t('recordsJumpToWeek');
  String get recordsBackToToday => _t('recordsBackToToday');
  String get recordsForecastHint => _t('recordsForecastHint');
  String get recordsDueListTitle => _t('recordsDueListTitle');
  String get recordsNoDue => _t('recordsNoDue');
  String get recordsOverview => _t('recordsOverview');
  String get recordsStreakLabel => _t('recordsStreakLabel');
  String get recordsLast7Days => _t('recordsLast7Days');
  String get recordsRetentionLabel => _t('recordsRetentionLabel');
  String get recordsMasteredLabel => _t('recordsMasteredLabel');
  String get recordsVocabularyLabel => _t('recordsVocabularyLabel');
  String get recordsTotalReviewsLabel => _t('recordsTotalReviewsLabel');
  String get recordsRetry => _t('recordsRetry');
  String get recordsLoadFailed => _t('recordsLoadFailed');
  String get recordsUnavailable => _t('recordsUnavailable');
  String get difficultyLabel => _t('difficultyLabel');
  String get stabilityLabel => _t('stabilityLabel');
  String daysLabel(String value) => _t('daysLabel', {'value': value});
  String get nextReviewLabel => _t('nextReviewLabel');
  String get lastReviewLabel => _t('lastReviewLabel');
  String get forgettingCurve => _t('forgettingCurve');
  String currentRetrievability(int percent) =>
      _t('currentRetrievability', {'percent': '$percent'});
  String get neverReviewed => _t('neverReviewed');
  String get cardHistoryTitle => _t('cardHistoryTitle');
  String get noCardHistory => _t('noCardHistory');
  String get wordViewTitle => _t('wordViewTitle');
  String get wordViewEmpty => _t('wordViewEmpty');
  String get edit => _t('edit');
  String get delete => _t('delete');
  String get deleteWordTitle => _t('deleteWordTitle');
  String deleteWordConfirm(String word) =>
      _t('deleteWordConfirm', {'word': word});
  String get deleteSuccess => _t('deleteSuccess');
  String deleteFailed(String error) => _t('deleteFailed', {'error': error});
  String loadFailed(String error) => _t('loadFailed', {'error': error});
  String get familiarityLearning => _t('familiarityLearning');
  String get familiarityRelearning => _t('familiarityRelearning');
  String get familiarityReview => _t('familiarityReview');
  String get wordCardCorrect => _t('wordCardCorrect');
  String get wordCardMarkKnown => _t('wordCardMarkKnown');
  String get wordCardMarkKnownTitle => _t('wordCardMarkKnownTitle');
  String wordCardMarkKnownConfirm(String word) =>
      _t('wordCardMarkKnownConfirm', {'word': word});
  String learningSummary(int learned, int reviewed, int toReview) => _t(
    'learningSummary',
    {'learned': '$learned', 'reviewed': '$reviewed', 'toReview': '$toReview'},
  );
  String get learningSummaryTitle => _t('learningSummaryTitle');
  String get learningSummaryNextLabel => _t('learningSummaryNextLabel');
  String get learningSummaryEnd => _t('learningSummaryEnd');
  String get learningSummaryNextGroup => _t('learningSummaryNextGroup');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const Map<String, Map<String, String>> _localizedValues = {
  'en': {
    'appTitle': 'LexiGo - Flashcards',
    'tabStudy': 'Study',
    'tabRecords': 'Records',
    'tabMe': 'Me',
    'language': 'Language',
    'languageSystem': 'System',
    'languageChinese': '中文',
    'languageEnglish': 'English',
    'startPrompt': 'Do you know it?',
    'next': 'Next',
    'startLearning': 'Start',
    'learningTitle': 'Learn',
    'ratingEasy': 'Easy',
    'ratingGood': 'Good',
    'ratingHard': 'Hard',
    'ratingAgain': 'Again',
    'settingsWordManagement': 'Word management',
    'settingsWordManagementSubtitle': 'View and maintain words',
    'settingsEditSettings': 'Edit settings',
    'settingsEditSettingsSubtitle': 'Edit app settings',
    'settingsLanguage': 'Language',
    'settingsTheme': 'Theme',
    'settingsThemeColor': 'Theme color',
    'settingsFont': 'Font',
    'fontPickerTitle': 'Choose font',
    'fontSystem': 'System font',
    'fontSystemSubtitle': 'Use the font built into your operating system',
    'fontMiSans': 'MiSans',
    'fontMiSansSubtitle':
        'Xiaomi official font, downloaded from hyperos.mi.com',
    'fontHarmonyOS': 'HarmonyOS Sans',
    'fontHarmonyOSSubtitle':
        'Huawei official font, downloaded from developer.huawei.com',
    'fontDownloadTitle': 'Download font',
    'fontDownloadConfirm':
        '"{font}" is not bundled with the app. It will be downloaded from the font vendor\'s official website (about {size} MB, network required). Continue?',
    'fontOfficialSource': 'Official source',
    'fontLicenseHint':
        'Fonts remain the property of their vendors and are used for on-device UI display only.',
    'fontDownloadPreparing': 'Preparing download…',
    'fontDownloading':
        'Downloading font package… {percent}% ({received} MB / {total} MB)',
    'fontDownloadingUnknown': 'Downloading font package… {received} MB',
    'fontDownloadFailed': 'Font download failed: {error}',
    'fontApplied': '{font} applied',
    'fontNotAvailable':
        'The font package is incomplete. Please download it again.',
    'themeSystem': 'System',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'themeColorAuto': 'Auto',
    'themeColorPick': 'Choose color',
    'themeColorPickerTitle': 'Pick theme color',
    'themeColorHue': 'Hue',
    'themeColorSaturation': 'Saturation',
    'themeColorBrightness': 'Brightness',
    'themeColorHexLabel': 'Hex color',
    'themeColorHexHint': '#RRGGBB or #AARRGGBB',
    'themeColorHexInvalid': 'Invalid hex color',
    'settingsLogManagement': 'Log management',
    'settingsLogManagementSubtitle': 'View and manage logs',
    'settingsAbout': 'About',
    'settingsAboutSubtitle': 'LexiGo - Flashcards',
    'wordManagementTitle': 'Word management',
    'wordListTitle': 'Word list',
    'wordListSubtitle': 'View word list',
    'importWordListTitle': 'Import word list',
    'importWordListSubtitle': 'Import from external file',
    'exportWordListTitle': 'Export word list',
    'exportWordListSubtitle': 'Export to external file',
    'addWordTitle': 'Add word',
    'addWordSubtitle': 'Add a word to database',
    'selectLanguageTitle': 'Select language',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'importSuccess': 'Imported {count} items, skipped {skipped}.',
    'importFailed': 'Import failed: {error}',
    'importPreviewTitle': 'Confirm import',
    'importPreviewSummary':
        'Found {total} rows: {count} to import, {skipped} skipped (empty or duplicate).',
    'importInProgress': 'Importing…',
    'importNothingToImport': 'No new words to import',
    'addWordPageTitle': 'Add word',
    'editWordPageTitle': 'Edit word',
    'fieldLanguage': 'Language',
    'fieldOriginal': 'Original',
    'fieldTranslation': 'Translation',
    'fieldOriginalExample': 'Example',
    'fieldExampleTranslation': 'Example translation',
    'fieldUnitId': 'Unit ID',
    'fieldBookId': 'Book ID',
    'save': 'Save',
    'required': 'Required',
    'addSuccess': 'Added successfully',
    'addFailed': 'Add failed: {error}',
    'editSuccess': 'Updated successfully',
    'editFailed': 'Update failed: {error}',
    'logManagementTitle': 'Log management',
    'logClearConfirmTitle': 'Confirm clear',
    'logClearConfirmContent': 'Clear all logs? This action cannot be undone.',
    'logCleared': 'Logs cleared',
    'clearFailed': 'Clear failed: {error}',
    'logSizeTitle': 'Log size',
    'logViewTitle': 'View logs',
    'logViewSubtitle': 'View latest logs',
    'logPathNotFound': 'Log file path not found',
    'logEmpty': 'No logs',
    'logReadFailed': 'Failed to read logs: {error}',
    'logShareNotSupported': 'Log sharing is not supported on Linux',
    'logFileNotFound': 'Log file not found',
    'logShareSuccess': 'Log shared successfully',
    'logShareFailed': 'Failed to share log: {error}',
    'logAboutTitle': 'About logs',
    'logAboutSubtitle':
        'Logs are stored in app data and kept for 7 days, older logs are removed automatically.',
    'refreshInfo': 'Refresh',
    'clearLogs': 'Clear logs',
    'today': 'Today',
    'recordsEmptyDay': 'No study records on this day',
    'recordsReviewCount': '{count} reviews',
    'recordsWordCount': '{count} words',
    'recordsForgottenCount': '{count} forgotten',
    'recordsAverageTime': 'avg {seconds}s per word',
    'recordsDueLabel': 'Due review',
    'recordsOverdueLabel': 'Overdue',
    'recordsNewWordsLabel': 'New words',
    'recordsPreviousWeek': 'Previous week',
    'recordsNextWeek': 'Next week',
    'recordsJumpToWeek': 'Pick a date to jump to its week',
    'recordsBackToToday': 'Back to today',
    'recordsForecastHint':
        'Future dates are forecasts based on the current schedule.',
    'recordsDueListTitle': 'Scheduled words',
    'recordsNoDue': 'Nothing scheduled for this day',
    'recordsOverview': 'Study overview',
    'recordsStreakLabel': 'Streak',
    'recordsLast7Days': 'Reviews in the last 7 days',
    'recordsRetentionLabel': 'Retention (7d)',
    'recordsMasteredLabel': 'Mastered',
    'recordsVocabularyLabel': 'Vocabulary',
    'recordsTotalReviewsLabel': 'Total reviews',
    'recordsRetry': 'Retry',
    'recordsLoadFailed': 'Failed to load records',
    'recordsUnavailable': 'Records unavailable',
    'difficultyLabel': 'Difficulty',
    'stabilityLabel': 'Stability',
    'daysLabel': '{value} d',
    'nextReviewLabel': 'Next review',
    'lastReviewLabel': 'Last review',
    'forgettingCurve': 'Forgetting curve',
    'currentRetrievability': 'Recall probability {percent}%',
    'neverReviewed': 'Not reviewed yet',
    'cardHistoryTitle': 'Review history',
    'noCardHistory': 'No reviews yet',
    'wordViewTitle': 'Word list',
    'wordViewEmpty': 'No words',
    'edit': 'Edit',
    'delete': 'Delete',
    'deleteWordTitle': 'Delete word',
    'deleteWordConfirm': 'Delete {word}?',
    'deleteSuccess': 'Deleted',
    'deleteFailed': 'Delete failed: {error}',
    'loadFailed': 'Load failed: {error}',
    'familiarityLearning': 'New',
    'familiarityRelearning': 'Relearning',
    'familiarityReview': 'Review',
    'wordCardCorrect': 'Correct',
    'wordCardMarkKnown': 'Mark as known',
    'wordCardMarkKnownTitle': 'Mark as known?',
    'wordCardMarkKnownConfirm': 'Confirm marking "{word}" as known.',
    'learningSummary':
        '{learned} words learned, {reviewed} reviewed, {toReview} to review',
    'learningSummaryTitle': 'Summary',
    'learningSummaryNextLabel': 'Next word:',
    'learningSummaryEnd': 'End learning',
    'learningSummaryNextGroup': 'Next set',
  },
  'zh': {
    'appTitle': '背了么 - LexiGo',
    'tabStudy': '背',
    'tabRecords': '记录',
    'tabMe': '我的',
    'language': '语言',
    'languageSystem': '跟随系统',
    'languageChinese': '中文',
    'languageEnglish': 'English',
    'startPrompt': '你认识吗？',
    'next': '下一个',
    'startLearning': '开始学习',
    'learningTitle': '学习',
    'ratingEasy': '简单',
    'ratingGood': '还行',
    'ratingHard': '困难',
    'ratingAgain': '忘记',
    'settingsWordManagement': '单词管理',
    'settingsWordManagementSubtitle': '查看与维护单词数据',
    'settingsEditSettings': '编辑设置',
    'settingsEditSettingsSubtitle': '编辑应用设置',
    'settingsLanguage': '语言',
    'settingsTheme': '主题',
    'settingsThemeColor': '主题色',
    'settingsFont': '字体',
    'fontPickerTitle': '选择字体',
    'fontSystem': '系统字体',
    'fontSystemSubtitle': '跟随操作系统默认字体，不额外下载',
    'fontMiSans': 'MiSans',
    'fontMiSansSubtitle': '小米官方字体，从 hyperos.mi.com 下载',
    'fontHarmonyOS': 'HarmonyOS Sans',
    'fontHarmonyOSSubtitle': '华为官方字体，从 developer.huawei.com 下载',
    'fontDownloadTitle': '下载字体',
    'fontDownloadConfirm': '「{font}」不随应用分发，需要从字体官方网站下载（约 {size} MB，需联网）。是否继续？',
    'fontOfficialSource': '官方来源',
    'fontLicenseHint': '字体版权归字体厂商所有，仅用于本机界面显示。',
    'fontDownloadPreparing': '正在准备下载…',
    'fontDownloading': '正在下载字体包… {percent}%（{received} MB / {total} MB）',
    'fontDownloadingUnknown': '正在下载字体包… 已下载 {received} MB',
    'fontDownloadFailed': '字体下载失败: {error}',
    'fontApplied': '已应用 {font}',
    'fontNotAvailable': '字体包不完整，请重新下载。',
    'themeSystem': '跟随系统',
    'themeLight': '浅色',
    'themeDark': '深色',
    'themeColorAuto': '自动',
    'themeColorPick': '选择颜色',
    'themeColorPickerTitle': '选择主题色',
    'themeColorHue': '色相',
    'themeColorSaturation': '饱和度',
    'themeColorBrightness': '亮度',
    'themeColorHexLabel': '十六进制颜色',
    'themeColorHexHint': '#RRGGBB 或 #AARRGGBB',
    'themeColorHexInvalid': '无效的颜色值',
    'settingsLogManagement': '日志管理',
    'settingsLogManagementSubtitle': '查看和管理应用日志',
    'settingsAbout': '关于',
    'settingsAboutSubtitle': '背了么 - LexiGo',
    'wordManagementTitle': '单词管理',
    'wordListTitle': '查看单词',
    'wordListSubtitle': '查看单词清单',
    'importWordListTitle': '导入单词清单',
    'importWordListSubtitle': '从外部文件导入单词清单',
    'exportWordListTitle': '导出单词清单',
    'exportWordListSubtitle': '将单词清单导出到外部文件',
    'addWordTitle': '添加单词',
    'addWordSubtitle': '手动添加单词到数据库',
    'selectLanguageTitle': '选择语言',
    'cancel': '取消',
    'confirm': '确定',
    'importSuccess': '导入成功: {count} 条，跳过: {skipped} 条',
    'importFailed': '导入失败: {error}',
    'importPreviewTitle': '确认导入',
    'importPreviewSummary': '共 {total} 行：可导入 {count} 条，跳过 {skipped} 条（空行或重复）。',
    'importInProgress': '正在导入…',
    'importNothingToImport': '没有可导入的新单词',
    'addWordPageTitle': '添加单词',
    'editWordPageTitle': '编辑单词',
    'fieldLanguage': '语言',
    'fieldOriginal': '原文',
    'fieldTranslation': '翻译',
    'fieldOriginalExample': '原文例句',
    'fieldExampleTranslation': '例句翻译',
    'fieldUnitId': '单元ID',
    'fieldBookId': '书籍ID',
    'save': '保存',
    'required': '必填',
    'addSuccess': '添加成功',
    'addFailed': '添加失败: {error}',
    'editSuccess': '修改成功',
    'editFailed': '修改失败: {error}',
    'logManagementTitle': '日志管理',
    'logClearConfirmTitle': '确认清除',
    'logClearConfirmContent': '确定要清除所有日志吗？此操作不可恢复。',
    'logCleared': '日志已清除',
    'clearFailed': '清除失败: {error}',
    'logSizeTitle': '日志大小',
    'logViewTitle': '日志查看',
    'logViewSubtitle': '查看最新日志',
    'logPathNotFound': '未找到日志路径',
    'logEmpty': '暂无日志',
    'logReadFailed': '读取日志失败: {error}',
    'logShareNotSupported': 'Linux 系统不支持分享日志',
    'logFileNotFound': '未找到日志文件',
    'logShareSuccess': '日志分享成功',
    'logShareFailed': '分享日志失败: {error}',
    'logAboutTitle': '关于日志',
    'logAboutSubtitle': '日志文件保存在应用数据目录，最多保留7天，超过后自动删除旧日志。',
    'refreshInfo': '刷新信息',
    'clearLogs': '清除日志',
    'today': '今天',
    'recordsEmptyDay': '当天没有学习记录',
    'recordsReviewCount': '复习 {count} 次',
    'recordsWordCount': '涉及 {count} 词',
    'recordsForgottenCount': '未记住 {count} 个',
    'recordsAverageTime': '平均 {seconds} 秒/词',
    'recordsDueLabel': '到期复习',
    'recordsOverdueLabel': '积压',
    'recordsNewWordsLabel': '待学新词',
    'recordsPreviousWeek': '上一周',
    'recordsNextWeek': '下一周',
    'recordsJumpToWeek': '选择日期跳转到所在周',
    'recordsBackToToday': '回到今天',
    'recordsForecastHint': '未来日期为基于当前排程的预测。',
    'recordsDueListTitle': '预计到期单词',
    'recordsNoDue': '当天没有到期单词',
    'recordsOverview': '学习概览',
    'recordsStreakLabel': '连续学习',
    'recordsLast7Days': '近 7 天复习',
    'recordsRetentionLabel': '记忆保持率',
    'recordsMasteredLabel': '已掌握',
    'recordsVocabularyLabel': '词库',
    'recordsTotalReviewsLabel': '累计复习',
    'recordsRetry': '重试',
    'recordsLoadFailed': '记录加载失败',
    'recordsUnavailable': '记录不可用',
    'difficultyLabel': '记忆难度',
    'stabilityLabel': '记忆强度',
    'daysLabel': '{value} 天',
    'nextReviewLabel': '下次复习',
    'lastReviewLabel': '上次复习',
    'forgettingCurve': '遗忘曲线',
    'currentRetrievability': '当前记忆概率 {percent}%',
    'neverReviewed': '尚未复习',
    'cardHistoryTitle': '复习记录',
    'noCardHistory': '暂无复习记录',
    'wordViewTitle': '单词清单',
    'wordViewEmpty': '暂无单词',
    'edit': '编辑',
    'delete': '删除',
    'deleteWordTitle': '删除单词',
    'deleteWordConfirm': '确定删除 {word} 吗？',
    'deleteSuccess': '删除成功',
    'deleteFailed': '删除失败: {error}',
    'loadFailed': '加载失败: {error}',
    'familiarityLearning': '生疏',
    'familiarityRelearning': '不熟',
    'familiarityReview': '熟悉',
    'wordCardCorrect': '纠错',
    'wordCardMarkKnown': '标记为熟知',
    'wordCardMarkKnownTitle': '标记为熟知？',
    'wordCardMarkKnownConfirm': '确认将 "{word}" 标记为熟知。',
    'learningSummary': '已学 {learned} 个，复习 {reviewed} 个，还剩 {toReview} 个',
    'learningSummaryTitle': '总结',
    'learningSummaryNextLabel': '接下来的是：',
    'learningSummaryEnd': '结束学习',
    'learningSummaryNextGroup': '下一组单词',
  },
};
