// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_generated.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LexiGo - Flashcards';

  @override
  String get tabStudy => 'Study';

  @override
  String get tabRecords => 'Records';

  @override
  String get tabMe => 'Me';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get startPrompt => 'Do you know it?';

  @override
  String get next => 'Next';

  @override
  String get startLearning => 'Start';

  @override
  String get learningTitle => 'Learn';

  @override
  String get ratingEasy => 'Easy';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingAgain => 'Again';

  @override
  String get settingsWordManagement => 'Word management';

  @override
  String get settingsWordManagementSubtitle => 'View and maintain words';

  @override
  String get settingsEditSettings => 'Edit settings';

  @override
  String get settingsEditSettingsSubtitle => 'Edit app settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeColor => 'Theme color';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeColorAuto => 'Auto';

  @override
  String get themeColorPick => 'Choose color';

  @override
  String get themeColorPickerTitle => 'Pick theme color';

  @override
  String get themeColorHue => 'Hue';

  @override
  String get themeColorSaturation => 'Saturation';

  @override
  String get themeColorBrightness => 'Brightness';

  @override
  String get themeColorHexLabel => 'Hex color';

  @override
  String get themeColorHexHint => '#RRGGBB or #AARRGGBB';

  @override
  String get themeColorHexInvalid => 'Invalid hex color';

  @override
  String get settingsLogManagement => 'Log management';

  @override
  String get settingsLogManagementSubtitle => 'View and manage logs';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'LexiGo - Flashcards';

  @override
  String get wordManagementTitle => 'Word management';

  @override
  String get wordListTitle => 'Word list';

  @override
  String get wordListSubtitle => 'View word list';

  @override
  String get importWordListTitle => 'Import word list';

  @override
  String get importWordListSubtitle => 'Import from external file';

  @override
  String get exportWordListTitle => 'Export word list';

  @override
  String get exportWordListSubtitle => 'Export to external file';

  @override
  String get exportFailedNoFolder =>
      'Export failed, download folder not found.';

  @override
  String get exportFailedUserDismiss => 'Export failed, user dismissed.';

  @override
  String get exportFailedUnavailable => 'Export failed, unavailable method.';

  @override
  String exportSuccess(Object filePath) {
    return 'Export success, file at $filePath.';
  }

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error.';
  }

  @override
  String get addWordTitle => 'Add word';

  @override
  String get addWordSubtitle => 'Add a word to database';

  @override
  String get selectLanguageTitle => 'Select language';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String importSuccess(Object count, Object skipped) {
    return 'Imported $count items, skipped $skipped.';
  }

  @override
  String importFailed(Object error) {
    return 'Import failed: $error.';
  }

  @override
  String get addWordPageTitle => 'Add word';

  @override
  String get editWordPageTitle => 'Edit word';

  @override
  String get fieldLanguage => 'Language';

  @override
  String get fieldOriginal => 'Original';

  @override
  String get fieldTranslation => 'Translation';

  @override
  String get fieldOriginalExample => 'Example';

  @override
  String get fieldExampleTranslation => 'Example translation';

  @override
  String get fieldUnitId => 'Unit ID';

  @override
  String get fieldBookId => 'Book ID';

  @override
  String get save => 'Save';

  @override
  String get required => 'Required';

  @override
  String get addSuccess => 'Added successfully';

  @override
  String addFailed(Object error) {
    return 'Add failed: $error.';
  }

  @override
  String get editSuccess => 'Updated successfully';

  @override
  String editFailed(Object error) {
    return 'Update failed: $error.';
  }

  @override
  String get logManagementTitle => 'Log management';

  @override
  String get logClearConfirmTitle => 'Confirm clear';

  @override
  String get logClearConfirmContent =>
      'Clear all logs? This action cannot be undone.';

  @override
  String get logCleared => 'Logs cleared';

  @override
  String clearFailed(Object error) {
    return 'Clear failed: $error.';
  }

  @override
  String get logSizeTitle => 'Log size';

  @override
  String get logViewTitle => 'View logs';

  @override
  String get logViewSubtitle => 'View latest logs';

  @override
  String get logPathNotFound => 'Log file path not found';

  @override
  String get logEmpty => 'No logs';

  @override
  String logReadFailed(Object error) {
    return 'Failed to read logs: $error.';
  }

  @override
  String get logShareNotSupported => 'Log sharing is not supported on Linux';

  @override
  String get logFileNotFound => 'Log file not found';

  @override
  String get logShareSuccess => 'Log shared successfully';

  @override
  String logShareFailed(Object error) {
    return 'Failed to share log: $error.';
  }

  @override
  String get logAboutTitle => 'About logs';

  @override
  String get logAboutSubtitle =>
      'Logs are stored in app data and kept for 7 days, older logs are removed automatically.';

  @override
  String get refreshInfo => 'Refresh';

  @override
  String get clearLogs => 'Clear logs';

  @override
  String get recordsBuilding => 'Coming soon...';

  @override
  String get wordViewTitle => 'Word list';

  @override
  String get wordViewEmpty => 'No words';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteWordTitle => 'Delete word';

  @override
  String deleteWordConfirm(Object word) {
    return 'Delete $word?';
  }

  @override
  String get deleteSuccess => 'Deleted';

  @override
  String deleteFailed(Object error) {
    return 'Delete failed: $error.';
  }

  @override
  String loadFailed(Object error) {
    return 'Load failed: $error.';
  }

  @override
  String get familiarityLearning => 'New';

  @override
  String get familiarityRelearning => 'Relearning';

  @override
  String get familiarityReview => 'Review';

  @override
  String get wordCardCorrect => 'Correct';

  @override
  String get wordCardMarkKnown => 'Mark as known';

  @override
  String get wordCardMarkKnownTitle => 'Mark as known?';

  @override
  String wordCardMarkKnownConfirm(Object word) {
    return 'Confirm marking \"$word\" as known.';
  }

  @override
  String learningSummary(Object learned, Object reviewed, Object toReview) {
    return '$learned words learned, $reviewed reviewed, $toReview to review';
  }

  @override
  String get learningSummaryTitle => 'Summary';

  @override
  String get learningSummaryNextLabel => 'Next word:';

  @override
  String get learningSummaryEnd => 'End learning';

  @override
  String get learningSummaryNextGroup => 'Next set';

  @override
  String get newWordHint => 'This is a new word to you :)';

  @override
  String get newWordHintEasterEgg => '❤️ ;D';

  @override
  String get settingsFont => 'Font';

  @override
  String get fontPickerTitle => 'Choose font';

  @override
  String get fontSystem => 'System font';

  @override
  String get fontSystemSubtitle =>
      'Use the font built into your operating system';

  @override
  String get fontMiSans => 'MiSans';

  @override
  String get fontMiSansSubtitle =>
      'Xiaomi official font, downloaded from hyperos.mi.com';

  @override
  String get fontHarmonyOS => 'HarmonyOS Sans';

  @override
  String get fontHarmonyOSSubtitle =>
      'Huawei official font, downloaded from developer.huawei.com';

  @override
  String get fontDownloadTitle => 'Download font';

  @override
  String fontDownloadConfirm(Object font, Object size) {
    return '\"$font\" is not bundled with the app. It will be downloaded from the font vendor\'s official website (about $size MB, network required). Continue?';
  }

  @override
  String get fontOfficialSource => 'Official source';

  @override
  String get fontLicenseHint =>
      'Fonts remain the property of their vendors and are used for on-device UI display only.';

  @override
  String get fontDownloadPreparing => 'Preparing download…';

  @override
  String fontDownloading(Object percent, Object received, Object total) {
    return 'Downloading font package… $percent% ($received MB / $total MB)';
  }

  @override
  String fontDownloadingUnknown(Object received) {
    return 'Downloading font package… $received MB';
  }

  @override
  String fontDownloadFailed(Object error) {
    return 'Font download failed: $error';
  }

  @override
  String fontApplied(Object font) {
    return '$font applied';
  }

  @override
  String get fontNotAvailable =>
      'The font package is incomplete. Please download it again.';

  @override
  String get importPreviewTitle => 'Confirm import';

  @override
  String importPreviewSummary(Object total, Object count, Object skipped) {
    return 'Found $total rows: $count to import, $skipped skipped (empty or duplicate).';
  }

  @override
  String get importInProgress => 'Importing…';

  @override
  String get importNothingToImport => 'No new words to import';

  @override
  String get today => 'Today';

  @override
  String get recordsEmptyDay => 'No study records on this day';

  @override
  String recordsReviewCount(Object count) {
    return '$count reviews';
  }

  @override
  String recordsWordCount(Object count) {
    return '$count words';
  }

  @override
  String recordsForgottenCount(Object count) {
    return '$count forgotten';
  }

  @override
  String recordsAverageTime(Object seconds) {
    return 'avg ${seconds}s per word';
  }

  @override
  String get recordsDueLabel => 'Due review';

  @override
  String get recordsOverdueLabel => 'Overdue';

  @override
  String get recordsNewWordsLabel => 'New words';

  @override
  String get recordsPreviousWeek => 'Previous week';

  @override
  String get recordsNextWeek => 'Next week';

  @override
  String get recordsJumpToWeek => 'Pick a date to jump to its week';

  @override
  String get recordsBackToToday => 'Back to today';

  @override
  String get recordsForecastHint =>
      'Future dates are forecasts based on the current schedule.';

  @override
  String get recordsDueListTitle => 'Scheduled words';

  @override
  String get recordsNoDue => 'Nothing scheduled for this day';

  @override
  String get recordsOverview => 'Study overview';

  @override
  String get recordsStreakLabel => 'Streak';

  @override
  String get recordsLast7Days => 'Reviews in the last 7 days';

  @override
  String get recordsRetentionLabel => 'Retention (7d)';

  @override
  String get recordsMasteredLabel => 'Mastered';

  @override
  String get recordsVocabularyLabel => 'Vocabulary';

  @override
  String get recordsTotalReviewsLabel => 'Total reviews';

  @override
  String get recordsRetry => 'Retry';

  @override
  String get recordsLoadFailed => 'Failed to load records';

  @override
  String get recordsUnavailable => 'Records unavailable';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get stabilityLabel => 'Stability';

  @override
  String daysLabel(Object value) {
    return '$value d';
  }

  @override
  String get nextReviewLabel => 'Next review';

  @override
  String get lastReviewLabel => 'Last review';

  @override
  String get forgettingCurve => 'Forgetting curve';

  @override
  String currentRetrievability(Object percent) {
    return 'Recall probability $percent%';
  }

  @override
  String get neverReviewed => 'Not reviewed yet';

  @override
  String get cardHistoryTitle => 'Review history';

  @override
  String get noCardHistory => 'No reviews yet';
}
