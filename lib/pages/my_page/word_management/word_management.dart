/// Word management interface for importing, exporting, and adding words.
///
/// Provides options to manage words through import/export, add new words,
/// and view the word database.
library;

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:drift_flutter/drift_flutter.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/database/interface.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/import_service.dart';
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/permission_manager.dart';
import 'package:lexigo/utils/settings.dart';

/// Word management menu page.
class WordManagement extends StatefulWidget {
  const WordManagement({super.key});

  @override
  State<WordManagement> createState() => _WordManagementState();
}

class _WordManagementState extends State<WordManagement> {
  final WordImportService _importService = WordImportService();
  final WordManager _wordManager = WordManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.wordManagementTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text(context.l10n.wordListTitle),
            subtitle: Text(context.l10n.wordListSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening word list page');
              Navigator.push(context, AppRoutes.wordList());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(context.l10n.importWordListTitle),
            subtitle: Text(context.l10n.importWordListSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Selecting file to import word list');
              _importWords();
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: Text(context.l10n.exportWordListTitle),
            subtitle: Text(context.l10n.exportWordListSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Selecting file to export word list');
              _exportWords();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(context.l10n.addWordTitle),
            subtitle: Text(context.l10n.addWordSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening add word page');
              Navigator.push(context, AppRoutes.wordAdd());
            },
          ),
        ],
      ),
    );
  }

  /// Runs the three-step import flow: inspect -> preview -> commit.
  Future<void> _importWords() async {
    await PermissionManager.makeSureReadExternalPermission();
    const XTypeGroup sqliteTypeGroup = XTypeGroup(
      label: 'SQLite Databases',
      extensions: <String>['sqlite', 'db'],
      uniformTypeIdentifiers: <String>['public.database'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[sqliteTypeGroup],
    );
    if (file == null) {
      AppLogger.info('User canceled file selection');
      return;
    }

    try {
      final List<LanguageCode> languages = await _importService.detectLanguages(
        file.path,
      );
      if (!mounted) return;
      if (languages.isEmpty) {
        throw const WordImportException(
          'No ko / ru / en table found in the selected file.',
        );
      }

      final LanguageCode? language = languages.length == 1
          ? languages.first
          : await _selectLanguage(languages);
      if (language == null) {
        AppLogger.info('User canceled language selection');
        return;
      }

      final ImportPlan plan = await _importService.prepare(
        path: file.path,
        language: language,
      );
      if (!mounted) return;
      if (plan.isEmpty) {
        _showMessage(context.l10n.importNothingToImport);
        return;
      }

      final bool? confirmed = await _confirmImport(plan);
      if (confirmed != true) {
        AppLogger.info('User canceled import');
        return;
      }
      await _runImport(plan);
    } on WordImportException catch (error, stackTrace) {
      AppLogger.error(
        'Word import rejected',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(context.l10n.importFailed(error.message));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to import words',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(context.l10n.importFailed('$error'));
    }
  }

  /// Commits [plan] behind a non-dismissible progress dialog.
  Future<void> _runImport(ImportPlan plan) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    final progress = ValueNotifier<double>(0);
    final dialog = _showProgressDialog(progress);
    try {
      await _importService.commit(
        plan,
        onProgress: (done, total) {
          progress.value = total == 0 ? 1 : done / total;
        },
      );
    } finally {
      // The dialog lives on the root navigator, so it can be closed without
      // borrowing this page's context again.
      if (navigator.mounted) {
        navigator.pop();
        await dialog;
      }
      progress.dispose();
    }

    AppLogger.info(
      'Import completed: ${plan.importCount} words, '
      'skipped ${plan.skippedCount}',
    );
    if (!mounted) return;
    _showMessage(
      context.l10n.importSuccess(plan.importCount, plan.skippedCount),
    );
  }

  /// Shows what is about to be imported and asks for confirmation.
  Future<bool?> _confirmImport(ImportPlan plan) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.importPreviewTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dialogContext.l10n.fieldLanguage}: ${plan.language.name}',
              ),
              const SizedBox(height: 8),
              Text(
                dialogContext.l10n.importPreviewSummary(
                  plan.totalRows,
                  plan.importCount,
                  plan.skippedCount,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  /// Non-dismissible dialog driven by [progress].
  Future<void> _showProgressDialog(ValueListenable<double> progress) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(dialogContext.l10n.importInProgress),
            content: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(value: value),
                    const SizedBox(height: 12),
                    Text('${(value * 100).round()}%', textAlign: TextAlign.end),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Exports the selected language (words + review history) to a new SQLite
  /// file and hands the file to the platform.
  ///
  /// The database is written to a temporary file first, then shared through the
  /// system share sheet on Apple platforms, copied to `Documents/LexiGo` on
  /// Android, or copied to the download directory on desktop.
  Future<void> _exportWords() async {
    final LanguageCode? languageCode = await _selectLanguage(
      LanguageCode.values,
    );
    if (languageCode == null) return;

    final List<Word> words = await _wordManager.getWords(languageCode);
    final DateTime now = DateTime.now();

    final List<WordTableCompanion> wordCompanions = [
      for (final Word word in words)
        _wordManager.wordToCompanion(word, createdAt: now, updatedAt: now),
    ];
    final Set<int> exportedCardIds = {
      for (final Word word in words) word.card.cardId,
    };
    final List<WordLearningHistoryTableCompanion> reviewLogCompanions = [
      for (final fsrs.ReviewLog reviewLog
          in (await _wordManager.getReviewLogs()).where(
            (log) => exportedCardIds.contains(log.cardId),
          ))
        _wordManager.reviewLogToCompanion(reviewLog),
    ];

    if (!mounted) return;
    final Directory directory = await getTemporaryDirectory();
    final String exportFileName =
        'lexigo_export_${languageCode.name}_'
        '${DateFormat('yyyyMMdd_HHmmss').format(now)}.sqlite';
    final File tempFile = File('${directory.path}/$exportFileName');

    try {
      final Database externalDatabase = Database.external(
        driftDatabase(
          name: 'lexigo_export_temp',
          native: DriftNativeOptions(
            databasePath: () => Future<String>.value(tempFile.path),
          ),
        ),
      );
      try {
        await externalDatabase.batch((batch) {
          batch.insertAll(externalDatabase.wordTable, wordCompanions);
          batch.insertAll(
            externalDatabase.wordLearningHistoryTable,
            reviewLogCompanions,
          );
        });
      } finally {
        await externalDatabase.close();
      }

      late File targetFile;
      if (Platform.isIOS || Platform.isMacOS) {
        final ShareResult result = await SharePlus.instance.share(
          ShareParams(files: [XFile(tempFile.path)]),
        );
        if (result.status == ShareResultStatus.dismissed) {
          if (!mounted) return;
          _showMessage(context.l10n.exportFailedUserDismiss);
          return;
        }
        if (result.status == ShareResultStatus.unavailable) {
          if (!mounted) return;
          _showMessage(context.l10n.exportFailedUnavailable);
          return;
        }
        targetFile = tempFile;
      } else if (Platform.isAndroid) {
        // TODO: Let the user pick the destination directory through SAF.
        final Directory outputDirectory = Directory(
          '/storage/emulated/0/Documents/LexiGo',
        );
        if (!await outputDirectory.exists()) {
          await outputDirectory.create(recursive: true);
        }
        targetFile = File('${outputDirectory.path}/$exportFileName');
        await tempFile.copy(targetFile.path);
      } else {
        final Directory? downloadsDirectory = await getDownloadsDirectory();
        if (downloadsDirectory == null) {
          if (!mounted) return;
          _showMessage(context.l10n.exportFailedNoFolder);
          return;
        }
        targetFile = File('${downloadsDirectory.path}/$exportFileName');
        await tempFile.copy(targetFile.path);
      }

      AppLogger.info('Word export completed: ${targetFile.path}');
      if (!mounted) return;
      _showMessage(context.l10n.exportSuccess(targetFile.path));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Word export failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(context.l10n.exportFailed('$error'));
    }
  }

  /// Lets the user pick one of [options].
  ///
  /// The currently studied language is preselected when it is one of them.
  Future<LanguageCode?> _selectLanguage(List<LanguageCode> options) {
    LanguageCode selected = SettingsStore.instance.settings.learningLanguage;
    if (!options.contains(selected)) {
      selected = options.first;
    }
    return showDialog<LanguageCode>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(dialogContext.l10n.selectLanguageTitle),
              content: DropdownButton<LanguageCode>(
                value: selected,
                items: options
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selected = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(dialogContext.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: Text(dialogContext.l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
