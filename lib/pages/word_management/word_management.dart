// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_selector/file_selector.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Project imports:
import 'package:lexigo/datas/orm/words.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/word_management/word_add_page.dart';
import 'package:lexigo/pages/word_management/word_view_page.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/permission_manager.dart';

class WordManagement extends StatelessWidget {
  const WordManagement({super.key});

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordViewPage()),
              );
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
              _importWords(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: Text(context.l10n.exportWordListTitle),
            subtitle: Text(context.l10n.exportWordListSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Selecting file to export word list');
              _exportWords(context);
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
    sqlite.Database? externalDb;
    try {
      AppLogger.info('Starting to import external SQLite: ${file.path}');
      externalDb = sqlite.sqlite3.open(file.path);

      final validTableNames = LanguageCode.values.map((e) => e.name).toSet();
      final tableRows = externalDb.select(
        "SELECT name FROM sqlite_master WHERE type='table';",
      );
      final tableNames = tableRows
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();
      final matched = tableNames.intersection(validTableNames);

      String tableName;
      LanguageCode language;
      if (matched.length == 1) {
        tableName = matched.first;
        language = LanguageCode.values
            .firstWhere((item) => item.name == tableName);
        AppLogger.info('Automatically detected language table: $tableName');
      } else {
        if (!context.mounted) return;
        final LanguageCode? selected = await _selectLanguage(context);
        if (selected == null) {
          AppLogger.info('User canceled language selection');
          return;
        }
        language = selected;
        tableName = language.name;
        final exists = tableNames.contains(tableName);
        if (!exists) {
          throw Exception('Table not found: $tableName');
        }
      }

      final requiredColumns = <String>{
        'original_word',
        'translation',
        'original_example',
        'example_translation',
        'unit_id',
        'book_id',
      };
      final columnInfo = externalDb.select(
        'PRAGMA table_info("$tableName");',
      );
      final existingColumns = columnInfo
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();
      final missingColumns = requiredColumns.difference(existingColumns);
      if (missingColumns.isNotEmpty) {
        throw Exception('Missing columns: ${missingColumns.join(', ')}');
      }

      final rows = externalDb.select(
        'SELECT original_word, translation, original_example, '
        'example_translation, unit_id, book_id FROM "$tableName";',
      );
      if (rows.isEmpty) {
        throw Exception('No data found');
      }

      final dao = await WordDao.open();
      final existing = await dao.getWords(language);
      final existingKeys = existing
          .map((word) => '${word.originalWord}||${word.bookID}||${word.unitID}')
          .toSet();
      final seenKeys = <String>{...existingKeys};

      final words = <Word>[];
      int skipped = 0;
      for (final row in rows) {
        final originalWord = row['original_word']?.toString().trim() ?? '';
        final translation = row['translation']?.toString().trim() ?? '';
        final originalExample = row['original_example']?.toString().trim() ?? '';
        final exampleTranslation =
            row['example_translation']?.toString().trim() ?? '';
        final unitId = (row['unit_id']?.toString().trim().isEmpty ?? true)
            ? 'DefaultUnit'
            : row['unit_id']!.toString().trim();
        final bookId = (row['book_id']?.toString().trim().isEmpty ?? true)
            ? 'DefaultBook'
            : row['book_id']!.toString().trim();

        if (originalWord.isEmpty || translation.isEmpty) {
          skipped += 1;
          continue;
        }

        final key = '$originalWord||$bookId||$unitId';
        if (seenKeys.contains(key)) {
          skipped += 1;
          continue;
        }

        final card = fsrs.Card.create();
        words.add(
          Word(
            originalWord: originalWord,
            translation: translation,
            originalExample: originalExample,
            exampleTranslation: exampleTranslation,
            sourceLanguageCode: language,
            card: card,
            unitID: unitId,
            bookID: bookId,
          ),
        );
        seenKeys.add(key);
      }

      await dao.insertWords(language, words);
      AppLogger.info('Import completed: ${words.length} words, skipped: $skipped words');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.importSuccess(words.length, skipped)),
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to import words', error: e, stackTrace: stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.importFailed('$e'))),
      );
    } finally {
      externalDb?.close();
    }
  }


  Future<void> _exportWords(BuildContext context) async {
    if (!context.mounted) return;
    final LanguageCode? selected = await _selectLanguage(context);
    if (selected == null) return;
    
  }

  Future<LanguageCode?> _selectLanguage(BuildContext context) async {
    LanguageCode selected = LanguageCode.ko;
    return showDialog<LanguageCode>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n.selectLanguageTitle),
              content: DropdownButton<LanguageCode>(
                value: selected,
                items: LanguageCode.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      ),
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
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, selected),
                  child: Text(context.l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
