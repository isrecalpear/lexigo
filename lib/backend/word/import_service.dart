/// Reads external SQLite word lists and writes them into the app database.
///
/// Importing is split into two explicit phases so the UI can show a preview and
/// a progress indicator:
/// 1. [WordImportService.prepare] validates the file, de-duplicates rows and
///    returns an [ImportPlan] without writing anything.
/// 2. [WordImportService.commit] persists the plan in chunked transactions.
library;

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Thrown when the selected file cannot be used as a word list.
class WordImportException implements Exception {
  const WordImportException(this.message);

  /// Human readable explanation of what is wrong with the file.
  final String message;

  @override
  String toString() => message;
}

/// One usable row read from an external word list.
class ImportRow {
  const ImportRow({
    required this.originalWord,
    required this.originalTranslation,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.unitId,
    required this.bookId,
  });

  final String originalWord;
  final String originalTranslation;
  final String exampleSentence;
  final String exampleTranslation;
  final String unitId;
  final String bookId;

  /// Key used to detect duplicates across the store and within the file.
  String get identityKey => '$originalWord||$bookId||$unitId';

  /// Converts the row into a [Word] with the given [card].
  Word toWord({required LanguageCode language, required fsrs.Card card}) {
    return Word(
      originalWord: originalWord,
      originalTranslation: originalTranslation,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      sourceLanguageCode: language,
      card: card,
      unitID: unitId,
      bookID: bookId,
    );
  }
}

/// The result of reading a file, before anything is written to the database.
class ImportPlan {
  const ImportPlan({
    required this.language,
    required this.rows,
    required this.totalRows,
    required this.skippedEmpty,
    required this.skippedDuplicate,
  });

  /// Language table the rows came from.
  final LanguageCode language;

  /// Rows that will be inserted.
  final List<ImportRow> rows;

  /// Number of rows present in the source table.
  final int totalRows;

  /// Rows dropped because the word or translation was blank.
  final int skippedEmpty;

  /// Rows dropped because the same word/book/unit already exists.
  final int skippedDuplicate;

  /// Number of words that will be inserted.
  int get importCount => rows.length;

  /// Number of rows that will not be imported.
  int get skippedCount => skippedEmpty + skippedDuplicate;

  /// Whether there is anything to write.
  bool get isEmpty => rows.isEmpty;
}

/// Imports word lists from external SQLite databases.
///
/// The expected layout is one table per language (`ko`, `ru`, `en`) with the
/// columns `original_word`, `translation`, `original_example`,
/// `example_translation`, `unit_id` and `book_id`.
class WordImportService {
  WordImportService({WordManager? wordManager})
    : _wordManager = wordManager ?? WordManager();

  final WordManager _wordManager;

  static const Set<String> _requiredColumns = {
    'original_word',
    'translation',
    'original_example',
    'example_translation',
    'unit_id',
    'book_id',
  };

  /// Returns the language tables contained in [path], in enum order.
  Future<List<LanguageCode>> detectLanguages(String path) async {
    final sqlite.Database db = _open(path);
    try {
      final Set<String> tableNames = db
          .select("SELECT name FROM sqlite_master WHERE type='table';")
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();
      final languages = LanguageCode.values
          .where((language) => tableNames.contains(language.name))
          .toList();
      AppLogger.info(
        'Detected import languages in $path: '
        '${languages.map((language) => language.name).join(', ')}',
      );
      return languages;
    } on sqlite.SqliteException catch (error) {
      AppLogger.error('Failed to read import file: $path', error: error);
      throw const WordImportException(
        'The selected file is not a readable SQLite database.',
      );
    } finally {
      db.close();
    }
  }

  /// Reads and validates [language]'s table without writing anything.
  ///
  /// Rows with an empty word/translation and rows already present in the
  /// database are dropped and counted in the returned [ImportPlan].
  Future<ImportPlan> prepare({
    required String path,
    required LanguageCode language,
  }) async {
    final sqlite.Database db = _open(path);
    try {
      final Set<String> columns = db
          .select('PRAGMA table_info("${language.name}");')
          .map((row) => row['name']?.toString())
          .whereType<String>()
          .toSet();
      final Set<String> missing = _requiredColumns.difference(columns);
      if (missing.isNotEmpty) {
        throw WordImportException(
          'Missing columns in table "${language.name}": '
          '${missing.join(', ')}',
        );
      }

      final rows = db.select(
        'SELECT original_word, translation, original_example, '
        'example_translation, unit_id, book_id FROM "${language.name}";',
      );
      final seenKeys = await _wordManager.getWordIdentityKeys(language);

      final imported = <ImportRow>[];
      int skippedEmpty = 0;
      int skippedDuplicate = 0;
      for (final row in rows) {
        final String originalWord =
            row['original_word']?.toString().trim() ?? '';
        final String translation = row['translation']?.toString().trim() ?? '';
        if (originalWord.isEmpty || translation.isEmpty) {
          skippedEmpty += 1;
          continue;
        }
        final ImportRow word = ImportRow(
          originalWord: originalWord,
          originalTranslation: translation,
          exampleSentence: row['original_example']?.toString().trim() ?? '',
          exampleTranslation:
              row['example_translation']?.toString().trim() ?? '',
          unitId: _defaultIfBlank(row['unit_id'], 'DefaultUnit'),
          bookId: _defaultIfBlank(row['book_id'], 'DefaultBook'),
        );
        if (!seenKeys.add(word.identityKey)) {
          skippedDuplicate += 1;
          continue;
        }
        imported.add(word);
      }

      AppLogger.info(
        'Prepared import for ${language.name}: '
        '${imported.length}/${rows.length} words, '
        'skipped empty: $skippedEmpty, duplicate: $skippedDuplicate',
      );
      return ImportPlan(
        language: language,
        rows: imported,
        totalRows: rows.length,
        skippedEmpty: skippedEmpty,
        skippedDuplicate: skippedDuplicate,
      );
    } on sqlite.SqliteException catch (error) {
      AppLogger.error('Failed to read import file: $path', error: error);
      throw const WordImportException(
        'The selected file is not a readable SQLite database.',
      );
    } finally {
      db.close();
    }
  }

  /// Writes [plan] in chunked transactions, reporting progress after each chunk.
  ///
  /// Cards get sequential ids starting at the current epoch millisecond instead
  /// of calling `Card.create()` per word; that helper sleeps 1ms per card to
  /// avoid id collisions, which made large imports take seconds.
  Future<void> commit(
    ImportPlan plan, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (plan.isEmpty) {
      return;
    }
    final int baseCardId = DateTime.now().millisecondsSinceEpoch;
    final words = <Word>[
      for (int i = 0; i < plan.rows.length; i++)
        plan.rows[i].toWord(
          language: plan.language,
          card: fsrs.Card(cardId: baseCardId + i),
        ),
    ];
    await _wordManager.insertWords(words, onProgress: onProgress);
    AppLogger.info('Committed import: ${words.length} words');
  }

  static sqlite.Database _open(String path) {
    try {
      return sqlite.sqlite3.open(path);
    } catch (error) {
      AppLogger.error('Failed to open import file: $path', error: error);
      throw const WordImportException(
        'The selected file is not a SQLite database.',
      );
    }
  }

  static String _defaultIfBlank(dynamic value, String fallback) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
