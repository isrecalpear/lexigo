// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'No AppLocalizations found in context');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  String get recordsBuilding => _t('recordsBuilding');
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
    'recordsBuilding': 'Coming soon...',
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
    'recordsBuilding': '开发中...',
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
  },
};
