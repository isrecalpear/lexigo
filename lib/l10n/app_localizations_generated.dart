import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_generated_en.dart';
import 'app_localizations_generated_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations_generated.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LexiGo - Flashcards'**
  String get appTitle;

  /// No description provided for @tabStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get tabStudy;

  /// No description provided for @tabRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabRecords;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @startPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you know it?'**
  String get startPrompt;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLearning;

  /// No description provided for @learningTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learningTitle;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @settingsWordManagement.
  ///
  /// In en, this message translates to:
  /// **'Word management'**
  String get settingsWordManagement;

  /// No description provided for @settingsWordManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and maintain words'**
  String get settingsWordManagementSubtitle;

  /// No description provided for @settingsEditSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit settings'**
  String get settingsEditSettings;

  /// No description provided for @settingsEditSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit app settings'**
  String get settingsEditSettingsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get settingsThemeColor;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeColorAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeColorAuto;

  /// No description provided for @themeColorPick.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get themeColorPick;

  /// No description provided for @themeColorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick theme color'**
  String get themeColorPickerTitle;

  /// No description provided for @themeColorHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get themeColorHue;

  /// No description provided for @themeColorSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get themeColorSaturation;

  /// No description provided for @themeColorBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get themeColorBrightness;

  /// No description provided for @themeColorHexLabel.
  ///
  /// In en, this message translates to:
  /// **'Hex color'**
  String get themeColorHexLabel;

  /// No description provided for @themeColorHexHint.
  ///
  /// In en, this message translates to:
  /// **'#RRGGBB or #AARRGGBB'**
  String get themeColorHexHint;

  /// No description provided for @themeColorHexInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid hex color'**
  String get themeColorHexInvalid;

  /// No description provided for @settingsLogManagement.
  ///
  /// In en, this message translates to:
  /// **'Log management'**
  String get settingsLogManagement;

  /// No description provided for @settingsLogManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage logs'**
  String get settingsLogManagementSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'LexiGo - Flashcards'**
  String get settingsAboutSubtitle;

  /// No description provided for @wordManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Word management'**
  String get wordManagementTitle;

  /// No description provided for @wordListTitle.
  ///
  /// In en, this message translates to:
  /// **'Word list'**
  String get wordListTitle;

  /// No description provided for @wordListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View word list'**
  String get wordListSubtitle;

  /// No description provided for @importWordListTitle.
  ///
  /// In en, this message translates to:
  /// **'Import word list'**
  String get importWordListTitle;

  /// No description provided for @importWordListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from external file'**
  String get importWordListSubtitle;

  /// No description provided for @exportWordListTitle.
  ///
  /// In en, this message translates to:
  /// **'Export word list'**
  String get exportWordListTitle;

  /// No description provided for @exportWordListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export to external file'**
  String get exportWordListSubtitle;

  /// No description provided for @exportFailedNoFolder.
  ///
  /// In en, this message translates to:
  /// **'Export failed, download folder not found.'**
  String get exportFailedNoFolder;

  /// No description provided for @exportFailedUserDismiss.
  ///
  /// In en, this message translates to:
  /// **'Export failed, user dismissed.'**
  String get exportFailedUserDismiss;

  /// No description provided for @exportFailedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Export failed, unavailable method.'**
  String get exportFailedUnavailable;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export success, file at {filePath}.'**
  String exportSuccess(Object filePath);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}.'**
  String exportFailed(Object error);

  /// No description provided for @addWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get addWordTitle;

  /// No description provided for @addWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a word to database'**
  String get addWordSubtitle;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items, skipped {skipped}.'**
  String importSuccess(Object count, Object skipped);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}.'**
  String importFailed(Object error);

  /// No description provided for @addWordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get addWordPageTitle;

  /// No description provided for @editWordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get editWordPageTitle;

  /// No description provided for @fieldLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get fieldLanguage;

  /// No description provided for @fieldOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get fieldOriginal;

  /// No description provided for @fieldTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get fieldTranslation;

  /// No description provided for @fieldOriginalExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get fieldOriginalExample;

  /// No description provided for @fieldExampleTranslation.
  ///
  /// In en, this message translates to:
  /// **'Example translation'**
  String get fieldExampleTranslation;

  /// No description provided for @fieldUnitId.
  ///
  /// In en, this message translates to:
  /// **'Unit ID'**
  String get fieldUnitId;

  /// No description provided for @fieldBookId.
  ///
  /// In en, this message translates to:
  /// **'Book ID'**
  String get fieldBookId;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addSuccess;

  /// No description provided for @addFailed.
  ///
  /// In en, this message translates to:
  /// **'Add failed: {error}.'**
  String addFailed(Object error);

  /// No description provided for @editSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get editSuccess;

  /// No description provided for @editFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}.'**
  String editFailed(Object error);

  /// No description provided for @logManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Log management'**
  String get logManagementTitle;

  /// No description provided for @logClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm clear'**
  String get logClearConfirmTitle;

  /// No description provided for @logClearConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Clear all logs? This action cannot be undone.'**
  String get logClearConfirmContent;

  /// No description provided for @logCleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared'**
  String get logCleared;

  /// No description provided for @clearFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear failed: {error}.'**
  String clearFailed(Object error);

  /// No description provided for @logSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Log size'**
  String get logSizeTitle;

  /// No description provided for @logViewTitle.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get logViewTitle;

  /// No description provided for @logViewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View latest logs'**
  String get logViewSubtitle;

  /// No description provided for @logPathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Log file path not found'**
  String get logPathNotFound;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get logEmpty;

  /// No description provided for @logReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read logs: {error}.'**
  String logReadFailed(Object error);

  /// No description provided for @logShareNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Log sharing is not supported on Linux'**
  String get logShareNotSupported;

  /// No description provided for @logFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Log file not found'**
  String get logFileNotFound;

  /// No description provided for @logShareSuccess.
  ///
  /// In en, this message translates to:
  /// **'Log shared successfully'**
  String get logShareSuccess;

  /// No description provided for @logShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share log: {error}.'**
  String logShareFailed(Object error);

  /// No description provided for @logAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About logs'**
  String get logAboutTitle;

  /// No description provided for @logAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Logs are stored in app data and kept for 7 days, older logs are removed automatically.'**
  String get logAboutSubtitle;

  /// No description provided for @refreshInfo.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshInfo;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get clearLogs;

  /// No description provided for @recordsBuilding.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get recordsBuilding;

  /// No description provided for @wordViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Word list'**
  String get wordViewTitle;

  /// No description provided for @wordViewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No words'**
  String get wordViewEmpty;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete word'**
  String get deleteWordTitle;

  /// No description provided for @deleteWordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {word}?'**
  String deleteWordConfirm(Object word);

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}.'**
  String deleteFailed(Object error);

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}.'**
  String loadFailed(Object error);

  /// No description provided for @familiarityLearning.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get familiarityLearning;

  /// No description provided for @familiarityRelearning.
  ///
  /// In en, this message translates to:
  /// **'Relearning'**
  String get familiarityRelearning;

  /// No description provided for @familiarityReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get familiarityReview;

  /// No description provided for @wordCardCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get wordCardCorrect;

  /// No description provided for @wordCardMarkKnown.
  ///
  /// In en, this message translates to:
  /// **'Mark as known'**
  String get wordCardMarkKnown;

  /// No description provided for @wordCardMarkKnownTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as known?'**
  String get wordCardMarkKnownTitle;

  /// No description provided for @wordCardMarkKnownConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm marking \"{word}\" as known.'**
  String wordCardMarkKnownConfirm(Object word);

  /// No description provided for @learningSummary.
  ///
  /// In en, this message translates to:
  /// **'{learned} words learned, {reviewed} reviewed, {toReview} to review'**
  String learningSummary(Object learned, Object reviewed, Object toReview);

  /// No description provided for @learningSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get learningSummaryTitle;

  /// No description provided for @learningSummaryNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next word:'**
  String get learningSummaryNextLabel;

  /// No description provided for @learningSummaryEnd.
  ///
  /// In en, this message translates to:
  /// **'End learning'**
  String get learningSummaryEnd;

  /// No description provided for @learningSummaryNextGroup.
  ///
  /// In en, this message translates to:
  /// **'Next set'**
  String get learningSummaryNextGroup;

  /// No description provided for @newWordHint.
  ///
  /// In en, this message translates to:
  /// **'This is a new word to you :)'**
  String get newWordHint;

  /// No description provided for @newWordHintEasterEgg.
  ///
  /// In en, this message translates to:
  /// **'❤️ ;D'**
  String get newWordHintEasterEgg;

  /// No description provided for @settingsFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get settingsFont;

  /// No description provided for @fontPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose font'**
  String get fontPickerTitle;

  /// No description provided for @fontSystem.
  ///
  /// In en, this message translates to:
  /// **'System font'**
  String get fontSystem;

  /// No description provided for @fontSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the font built into your operating system'**
  String get fontSystemSubtitle;

  /// No description provided for @fontMiSans.
  ///
  /// In en, this message translates to:
  /// **'MiSans'**
  String get fontMiSans;

  /// No description provided for @fontMiSansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi official font, downloaded from hyperos.mi.com'**
  String get fontMiSansSubtitle;

  /// No description provided for @fontHarmonyOS.
  ///
  /// In en, this message translates to:
  /// **'HarmonyOS Sans'**
  String get fontHarmonyOS;

  /// No description provided for @fontHarmonyOSSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Huawei official font, downloaded from developer.huawei.com'**
  String get fontHarmonyOSSubtitle;

  /// No description provided for @fontDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download font'**
  String get fontDownloadTitle;

  /// No description provided for @fontDownloadConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{font}\" is not bundled with the app. It will be downloaded from the font vendor\'s official website (about {size} MB, network required). Continue?'**
  String fontDownloadConfirm(Object font, Object size);

  /// No description provided for @fontOfficialSource.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get fontOfficialSource;

  /// No description provided for @fontLicenseHint.
  ///
  /// In en, this message translates to:
  /// **'Fonts remain the property of their vendors and are used for on-device UI display only.'**
  String get fontLicenseHint;

  /// No description provided for @fontDownloadPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing download…'**
  String get fontDownloadPreparing;

  /// No description provided for @fontDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading font package… {percent}% ({received} MB / {total} MB)'**
  String fontDownloading(Object percent, Object received, Object total);

  /// No description provided for @fontDownloadingUnknown.
  ///
  /// In en, this message translates to:
  /// **'Downloading font package… {received} MB'**
  String fontDownloadingUnknown(Object received);

  /// No description provided for @fontDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Font download failed: {error}'**
  String fontDownloadFailed(Object error);

  /// No description provided for @fontApplied.
  ///
  /// In en, this message translates to:
  /// **'{font} applied'**
  String fontApplied(Object font);

  /// No description provided for @fontNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'The font package is incomplete. Please download it again.'**
  String get fontNotAvailable;

  /// No description provided for @importPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'Found {total} rows: {count} to import, {skipped} skipped (empty or duplicate).'**
  String importPreviewSummary(Object total, Object count, Object skipped);

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importInProgress;

  /// No description provided for @importNothingToImport.
  ///
  /// In en, this message translates to:
  /// **'No new words to import'**
  String get importNothingToImport;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @recordsEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No study records on this day'**
  String get recordsEmptyDay;

  /// No description provided for @recordsReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String recordsReviewCount(Object count);

  /// No description provided for @recordsWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String recordsWordCount(Object count);

  /// No description provided for @recordsForgottenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} forgotten'**
  String recordsForgottenCount(Object count);

  /// No description provided for @recordsAverageTime.
  ///
  /// In en, this message translates to:
  /// **'avg {seconds}s per word'**
  String recordsAverageTime(Object seconds);

  /// No description provided for @recordsDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due review'**
  String get recordsDueLabel;

  /// No description provided for @recordsOverdueLabel.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get recordsOverdueLabel;

  /// No description provided for @recordsNewWordsLabel.
  ///
  /// In en, this message translates to:
  /// **'New words'**
  String get recordsNewWordsLabel;

  /// No description provided for @recordsPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get recordsPreviousWeek;

  /// No description provided for @recordsNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get recordsNextWeek;

  /// No description provided for @recordsJumpToWeek.
  ///
  /// In en, this message translates to:
  /// **'Pick a date to jump to its week'**
  String get recordsJumpToWeek;

  /// No description provided for @recordsBackToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get recordsBackToToday;

  /// No description provided for @recordsForecastHint.
  ///
  /// In en, this message translates to:
  /// **'Future dates are forecasts based on the current schedule.'**
  String get recordsForecastHint;

  /// No description provided for @recordsDueListTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled words'**
  String get recordsDueListTitle;

  /// No description provided for @recordsNoDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day'**
  String get recordsNoDue;

  /// No description provided for @recordsOverview.
  ///
  /// In en, this message translates to:
  /// **'Study overview'**
  String get recordsOverview;

  /// No description provided for @recordsStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get recordsStreakLabel;

  /// No description provided for @recordsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Reviews in the last 7 days'**
  String get recordsLast7Days;

  /// No description provided for @recordsRetentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Retention (7d)'**
  String get recordsRetentionLabel;

  /// No description provided for @recordsMasteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get recordsMasteredLabel;

  /// No description provided for @recordsVocabularyLabel.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get recordsVocabularyLabel;

  /// No description provided for @recordsTotalReviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total reviews'**
  String get recordsTotalReviewsLabel;

  /// No description provided for @recordsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get recordsRetry;

  /// No description provided for @recordsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load records'**
  String get recordsLoadFailed;

  /// No description provided for @recordsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Records unavailable'**
  String get recordsUnavailable;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @stabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stabilityLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} d'**
  String daysLabel(Object value);

  /// No description provided for @nextReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Next review'**
  String get nextReviewLabel;

  /// No description provided for @lastReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Last review'**
  String get lastReviewLabel;

  /// No description provided for @forgettingCurve.
  ///
  /// In en, this message translates to:
  /// **'Forgetting curve'**
  String get forgettingCurve;

  /// No description provided for @currentRetrievability.
  ///
  /// In en, this message translates to:
  /// **'Recall probability {percent}%'**
  String currentRetrievability(Object percent);

  /// No description provided for @neverReviewed.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed yet'**
  String get neverReviewed;

  /// No description provided for @cardHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get cardHistoryTitle;

  /// No description provided for @noCardHistory.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noCardHistory;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search words'**
  String get searchHint;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get showAnswer;

  /// No description provided for @hideAnswer.
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get hideAnswer;

  /// No description provided for @languageEnglishName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishName;

  /// No description provided for @languageKoreanName.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKoreanName;

  /// No description provided for @languageRussianName.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussianName;

  /// No description provided for @sectionStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get sectionStudy;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get sectionWords;

  /// No description provided for @sectionImportExport.
  ///
  /// In en, this message translates to:
  /// **'Import & export'**
  String get sectionImportExport;

  /// No description provided for @ratingPrompt.
  ///
  /// In en, this message translates to:
  /// **'How well did you remember?'**
  String get ratingPrompt;

  /// No description provided for @wordListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Import a word list or add words manually to start learning.'**
  String get wordListEmptyHint;

  /// No description provided for @summaryLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get summaryLearned;

  /// No description provided for @summaryReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get summaryReviewed;

  /// No description provided for @summaryToReview.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get summaryToReview;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or tap shuffle for another word'**
  String get swipeHint;

  /// No description provided for @recordsLast7DaysShort.
  ///
  /// In en, this message translates to:
  /// **'7-day reviews'**
  String get recordsLast7DaysShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
