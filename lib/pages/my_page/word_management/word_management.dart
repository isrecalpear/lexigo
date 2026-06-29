/// Word management interface for importing, exporting, and adding words.
///
/// Provides options to manage words through import/export, add new words,
/// and view the word database.
library;

// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:fsrs/fsrs.dart' as fsrs;

// Package imports:
import 'package:file_selector/file_selector.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/my_page/word_management/word_add.dart';
import 'package:lexigo/pages/my_page/word_management/word_view.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/permission_manager.dart';
import 'package:lexigo/backend/database/interface.dart';

/// Word management menu page.
class WordManagement extends StatelessWidget {
  final _wordManager = WordManager();
  WordManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wordManagementTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text(AppLocalizations.of(context)!.wordListTitle),
            subtitle: Text(AppLocalizations.of(context)!.wordListSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening word list page');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordViewPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(AppLocalizations.of(context)!.importWordListTitle),
            subtitle: Text(
              AppLocalizations.of(context)!.importWordListSubtitle,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Selecting file to import word list');
              _importWords(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: Text(AppLocalizations.of(context)!.exportWordListTitle),
            subtitle: Text(
              AppLocalizations.of(context)!.exportWordListSubtitle,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Selecting file to export word list');
              _exportWords(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(AppLocalizations.of(context)!.addWordTitle),
            subtitle: Text(AppLocalizations.of(context)!.addWordSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening add word page');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordAddPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _importWords(BuildContext context) async {
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

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/lexigo_import_temp.db');
    Database? externalDatabase;
    try {
      AppLogger.info('Copying external DB to temp: ${file.path}');
      await File(file.path).copy(tempFile.path);
      AppLogger.info('Copied to: ${tempFile.path}');
      final databaseQueryExecutor = driftDatabase(
        name: "lexigo_import_temp",
        native: DriftNativeOptions(
          databasePath: () => Future(() => tempFile.path),
        ),
      );
      externalDatabase = Database.external(databaseQueryExecutor);
      final wordRows = await externalDatabase
          .select(externalDatabase.wordTable)
          .get();
      AppLogger.info(
        'Read ${wordRows.length} rows of word(s) from external DB',
      );

      if (wordRows.isEmpty) {
        throw Exception('Empty DB');
      }
      final words = <Word>[];
      final reviewLogs = <fsrs.ReviewLog>[];

      for (final row in wordRows) {
        final word = _wordManager.tableDataToWord(row);
        final learningHistoryRows = await (externalDatabase.select(
          externalDatabase.wordLearningHistoryTable,
        )..where((t) => t.cardId.equals(row.cardId))).get();
        final card = await fsrs.Card.create();

        words.add(
          Word(
            originalWord: word.originalWord,
            originalTranslation: word.originalTranslation,
            exampleSentence: word.exampleTranslation,
            exampleTranslation: word.exampleTranslation,
            sourceLanguageCode: word.sourceLanguageCode,
            card: Future(() => card),
            unitID: word.unitID,
            bookID: word.bookID,
          ),
        );

        for (final learningHistoryRow in learningHistoryRows) {
          reviewLogs.add(
            fsrs.ReviewLog(
              cardId: card.cardId,
              rating: learningHistoryRow.rating,
              reviewDateTime: learningHistoryRow.reviewDateTime,
              reviewDuration: learningHistoryRow.reviewDuration,
            ),
          );
        }
      }

      _wordManager.insertWords(words);
      _wordManager.insertReviewLogs(reviewLogs);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.importSuccess(words.length, 0),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Import failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.importFailed('$e')),
          ),
        );
      }
    } finally {
      await externalDatabase?.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
        AppLogger.info('Temp file cleaned up: ${tempFile.path}');
      }
    }
  }

  Future<void> _exportWords(BuildContext context) async {
    if (!context.mounted) return;

    final LanguageCode? languageCode = await _selectLanguage(context);
    if (languageCode == null) return;

    final directory = await getTemporaryDirectory();

    final words = await _wordManager.getWords(languageCode);
    final wordsCompanion = <WordTableCompanion>[];
    final now = DateTime.now();
    for (final word in words) {
      wordsCompanion.add(
        await _wordManager.wordToCompanion(
          word,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    final reviewLogs = await _wordManager.getReviewLogs();
    final reviewLogsCompanion = <WordLearningHistoryTableCompanion>[];
    for (final reviewLog in reviewLogs) {
      reviewLogsCompanion.add(_wordManager.reviewLogToCompanion(reviewLog));
    }

    try {
      final exportFileName =
          'lexigo_export_${languageCode.name}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.sqlite';
      final tempFile = File('${directory.path}/$exportFileName');

      final databaseQueryExecutor = driftDatabase(
        name: "lexigo_export_temp",
        native: DriftNativeOptions(
          databasePath: () => Future(() => tempFile.path),
        ),
      );

      final externalDatabase = Database.external(databaseQueryExecutor);
      try {
        await externalDatabase.batch((batch) {
          batch.insertAll(externalDatabase.wordTable, wordsCompanion);
          batch.insertAll(
            externalDatabase.wordLearningHistoryTable,
            reviewLogsCompanion,
          );
        });
      } finally {
        await externalDatabase.close();
      }
      late File targetFile;
      if (Platform.isIOS || Platform.isMacOS) {
        final params = ShareParams(files: [XFile(tempFile.path)]);

        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.dismissed) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.exportFailedUserDismiss,
                ),
              ),
            );
          }
          return;
        } else if (result.status == ShareResultStatus.unavailable) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.exportFailedUnavailable,
                ),
              ),
            );
          }
          return;
        } else {
          targetFile = tempFile;
        }
      } else if (Platform.isAndroid) {
        /// TODO: Find a way to let user select directory
        final outputDirectory = '/storage/emulated/0/Documents/LexiGo';
        final dir = Directory(outputDirectory);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        targetFile = File('${dir.path}/$exportFileName');
        await tempFile.copy(targetFile.path);
      } else {
        final dict = await getDownloadsDirectory();

        if (dict == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.exportFailedNoFolder,
                ),
              ),
            );
          }
          return;
        }
        targetFile = File('${dict.path}/$exportFileName');
        await tempFile.copy(targetFile.path);
      }

      AppLogger.info('Export success, file at: ${targetFile.path}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.exportSuccess(targetFile.path),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Export failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.exportFailed('$e')),
          ),
        );
      }
    }
  }

  Future<LanguageCode?> _selectLanguage(BuildContext context) async {
    LanguageCode selected = LanguageCode.ko;
    return showDialog<LanguageCode>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectLanguageTitle),
              content: DropdownButton<LanguageCode>(
                value: selected,
                items: LanguageCode.values
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
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
