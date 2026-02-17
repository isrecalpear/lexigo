// Package imports:
import 'package:fsrs/fsrs.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'fallback_word.dart';
import 'database.dart';

class WordRepository {
  WordRepository._(this._db);

  final sqlite.Database _db;

  /// Opens a connection to the word database.
  static Future<WordRepository> open() async {
    final db = await Database.getInstance();
    return WordRepository._(db);
  }

  /// FSRS v5 algorithm parameters (from FSRS community defaults).
  static const List<double> _schedulerParameters = [
    0.212,
    1.2931,
    2.3065,
    8.2956,
    6.4133,
    0.8334,
    3.0194,
    0.001,
    1.8722,
    0.1666,
    0.796,
    1.4835,
    0.0614,
    0.2629,
    1.6483,
    0.6014,
    1.8729,
    0.5425,
    0.0912,
    0.0658,
    0.1542,
  ];

  /// Target retention rate for scheduling (0.9 = 90%).
  static const double _schedulerDesiredRetention = 0.9;

  /// Initial learning delays for new cards (1 min, then 10 min).
  static const List<Duration> _schedulerLearningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];

  /// Delays for cards being relearned after a failure (10 min).
  static const List<Duration> _schedulerRelearningSteps = [
    Duration(minutes: 10),
  ];

  /// Maximum interval (in days) between reviews to prevent forgotten cards.
  static const int _schedulerMaximumInterval = 36500;

  /// Whether to add randomization to scheduling.
  static const bool _schedulerEnableFuzzing = true;

  /// Shared FSRS scheduler instance with configured parameters.
  static final Scheduler scheduler = Scheduler(
    parameters: _schedulerParameters,
    desiredRetention: _schedulerDesiredRetention,
    learningSteps: _schedulerLearningSteps,
    relearningSteps: _schedulerRelearningSteps,
    maximumInterval: _schedulerMaximumInterval,
    enableFuzzing: _schedulerEnableFuzzing,
  );

  /// Inserts a batch of words for the specified language.
  /// Handles duplicates by updating existing entries based on card_id.
  Future<void> insertWords(LanguageCode language, List<Word> words) async {
    if (words.isEmpty) {
      return;
    }

    _ensureTable(language);
    final tableName = _tableName(language);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final stmt = _db.prepare('''
			INSERT INTO $tableName (
				original_word,
				translation,
				original_example,
				example_translation,
				unit_id,
				book_id,
				card_id,
				card_state,
				card_step,
				card_stability,
				card_difficulty,
				card_due,
				card_last_review,
				created_at,
				updated_at
			) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
			ON CONFLICT(card_id) DO UPDATE SET
				original_word = excluded.original_word,
				translation = excluded.translation,
				original_example = excluded.original_example,
				example_translation = excluded.example_translation,
				unit_id = excluded.unit_id,
				book_id = excluded.book_id,
				card_state = excluded.card_state,
				card_step = excluded.card_step,
				card_stability = excluded.card_stability,
				card_difficulty = excluded.card_difficulty,
				card_due = excluded.card_due,
				card_last_review = excluded.card_last_review,
				updated_at = excluded.updated_at;
		''');

    AppLogger.info('Start to insert words: ${words.length}');
    _db.execute('BEGIN');
    try {
      for (final word in words) {
        final map = await _toDbMap(word, now, now);
        stmt.execute(map);
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      AppLogger.error('Failed to insert words', error: e);
      rethrow;
    } finally {
      stmt.close();
    }

    _refreshWordCount(language);
  }

  /// Updates a single word in the database.
  /// Returns the number of rows affected.
  Future<int> updateWord(LanguageCode language, Word word) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final map = await _toDbMap(word, null, now);
    final stmt = _db.prepare('''
			UPDATE $tableName SET
				original_word = ?,
				translation = ?,
				original_example = ?,
				example_translation = ?,
				unit_id = ?,
				book_id = ?,
				card_state = ?,
				card_step = ?,
				card_stability = ?,
				card_difficulty = ?,
				card_due = ?,
				card_last_review = ?,
				updated_at = ?
			WHERE card_id = ?;
		''');

    try {
      stmt.execute([
        map[0],
        map[1],
        map[2],
        map[3],
        map[4],
        map[5],
        map[7],
        map[8],
        map[9],
        map[10],
        map[11],
        map[12],
        map[14],
        map[6],
      ]);
      AppLogger.info('Updated word successfully: ${word.originalWord}');
      return _changes();
    } finally {
      stmt.close();
    }
  }

  /// Deletes multiple words by their card IDs for the specified language.
  /// Returns the total number of deleted rows.
  Future<int> deleteWordsByCardIds(
    LanguageCode language,
    List<int> cardIds,
  ) async {
    if (cardIds.isEmpty) {
      return 0;
    }

    _ensureTable(language);
    final tableName = _tableName(language);
    int total = 0;

    AppLogger.info('Start to delete words in batch: ${cardIds.length}');
    _db.execute('BEGIN');
    try {
      for (final chunk in _chunk(cardIds, 500)) {
        final placeholders = List.filled(chunk.length, '?').join(',');
        final stmt = _db.prepare(
          'DELETE FROM $tableName WHERE card_id IN ($placeholders);',
        );
        try {
          stmt.execute(chunk);
          total += _changes();
        } finally {
          stmt.close();
        }
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      AppLogger.error('Failed to delete words in batch', error: e);
      rethrow;
    }

    _refreshWordCount(language);
    return total;
  }

  /// Retrieves all words for the specified language.
  /// Supports optional ordering, limiting, and pagination.
  Future<List<Word>> getWords(
    LanguageCode language, {
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final buffer = StringBuffer('SELECT * FROM $tableName');
    if (orderBy != null && orderBy.trim().isNotEmpty) {
      buffer.write(' ORDER BY $orderBy');
    }
    if (limit != null) {
      buffer.write(' LIMIT $limit');
    }
    if (offset != null) {
      buffer.write(' OFFSET $offset');
    }
    buffer.write(';');

    final result = _db.select(buffer.toString());
    AppLogger.debug('Retrieved word list: ${result.length}');
    return result.map((row) => _fromRow(row, language)).toList();
  }

  Future<Word> getRandomWord(LanguageCode language) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final result = _db.select(
      'SELECT * FROM $tableName ORDER BY RANDOM() LIMIT 1;',
    );
    if (result.isNotEmpty) {
      AppLogger.debug(
        'Retrieved random word successfully: ${result.first['original_word']}',
      );
      return _fromRow(result.first, language);
    } else {
      AppLogger.warning(
        'No words found for language: $language, returning fallback word',
      );
      return fallbackWordFor(language);
    }
  }

  /// Retrieves the next due review word for the specified language.
  /// Returns null if no review words are available.
  Future<Word?> getReviewWord(LanguageCode language) async {
    // get due cards from database, return the first one if exists
    _ensureTable(language);
    final tableName = _tableName(language);
    final result = _db.select('''
      SELECT * FROM $tableName
      ORDER BY card_due ASC
      LIMIT 1;
    ''');
    if (result.isNotEmpty) {
      AppLogger.debug(
        'Retrieved review word successfully: cardId=${result.first['card_id']}',
      );
      return _fromRow(result.first, language);
    }

    return null;
  }

  /// Searches for words matching the query string in the specified language.
  /// Searches across originalWord, translation, originalExample, and exampleTranslation fields.
  /// Supports case-insensitive fuzzy matching.
  /// [limit] defaults to 20 results.
  Future<List<Word>> searchWords(
    LanguageCode language,
    String query, {
    int limit = 20,
  }) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final String like = '%$query%';
    final result = _db.select(
      'SELECT * FROM $tableName '
      'WHERE original_word LIKE ? '
      'OR translation LIKE ? '
      'OR original_example LIKE ? '
      'OR example_translation LIKE ? '
      'ORDER BY card_due ASC '
      'LIMIT ?;',
      [like, like, like, like, limit],
    );
    AppLogger.debug('Search words: query="$query", count=${result.length}');
    return result.map((row) => _fromRow(row, language)).toList();
  }

  /// Processes a word review with the given rating.
  ///
  /// Updates the FSRS card state based on the rating and saves to database.
  /// Logs the scheduling result for debugging.
  Future<void> reviewWord(Word word, Rating rating) async {
    try {
      final card_ = await word.card;
      final (:card, :reviewLog) = scheduler.reviewCard(card_, rating);
      AppLogger.info(
        "Card rated ${reviewLog.rating} at ${reviewLog.reviewDateTime}",
      );

      final updatedWord = Word(
        originalWord: word.originalWord,
        translation: word.translation,
        originalExample: word.originalExample,
        exampleTranslation: word.exampleTranslation,
        sourceLanguageCode: word.sourceLanguageCode,
        card: Future.value(card),
        unitID: word.unitID,
        bookID: word.bookID,
      );

      await updateWord(word.sourceLanguageCode, updatedWord);

      final due = card.due;
      final timeDelta = due.difference(DateTime.now());
      AppLogger.debug("Card due on $due");
      AppLogger.debug("Card due in ${timeDelta.inSeconds} seconds");
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to review word',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> reviewWordsCount(LanguageCode language) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final result = _db.select(
      'SELECT COUNT(1) AS count FROM $tableName WHERE card_due <= ?;',
      [DateTime.now().toUtc().millisecondsSinceEpoch],
    );
    return result.first['count'] as int;
  }

  /// Ensures the language table exists in the database.
  void _ensureTable(LanguageCode language) {
    final languageCode = _languageCode(language);
    Database.ensureLanguageTable(_db, languageCode);
  }

  /// Returns the language code as a string representation.
  String _languageCode(LanguageCode language) {
    return language.name;
  }

  /// Returns the table name for the specified language.
  String _tableName(LanguageCode language) {
    return Database.tableNameForLanguage(_languageCode(language));
  }

  /// Converts a Word object to a database-compatible format.
  /// Returns a list of values in the order expected by the insert/update SQL.
  Future<List<Object?>> _toDbMap(
    Word word,
    int? createdAt,
    int updatedAt,
  ) async {
    final card = await word.card;
    final cardMap = card.toMap();
    final dueMillis = _requireEpochMillis(cardMap['due']);
    final lastReviewMillis = _toEpochMillis(cardMap['lastReview']);
    return [
      word.originalWord,
      word.translation,
      word.originalExample,
      word.exampleTranslation,
      word.unitID,
      word.bookID,
      cardMap['cardId'],
      cardMap['state'],
      cardMap['step'],
      cardMap['stability'],
      cardMap['difficulty'],
      dueMillis,
      lastReviewMillis,
      createdAt ?? DateTime.now().toUtc().millisecondsSinceEpoch,
      updatedAt,
    ];
  }

  /// Converts a database row to a Word object.
  Word _fromRow(sqlite.Row row, LanguageCode language) {
    final card = Card.fromMap({
      'cardId': row['card_id'] as int,
      'state': row['card_state'] as int,
      'step': row['card_step'] as int?,
      'stability': row['card_stability'] as double?,
      'difficulty': row['card_difficulty'] as double?,
      'due': _toIsoString(row['card_due']),
      'lastReview': _toNullableIsoString(row['card_last_review']),
    });

    return Word(
      originalWord: row['original_word'] as String,
      translation: row['translation'] as String,
      originalExample: row['original_example'] as String,
      exampleTranslation: row['example_translation'] as String,
      sourceLanguageCode: language,
      card: Future.value(card),
      unitID: (row['unit_id'] as String?) ?? 'DefaultUnit',
      bookID: (row['book_id'] as String?) ?? 'DefaultBook',
    );
  }

  /// Returns the number of rows affected by the last database operation.
  int _changes() {
    final result = _db.select('SELECT changes() AS count;');
    return result.first['count'] as int;
  }

  /// Splits a list into chunks of the specified size.
  List<List<int>> _chunk(List<int> values, int size) {
    final chunks = <List<int>>[];
    for (var i = 0; i < values.length; i += size) {
      chunks.add(
        values.sublist(i, i + size > values.length ? values.length : i + size),
      );
    }
    return chunks;
  }

  /// Updates the word count for the language table.
  void _refreshWordCount(LanguageCode language) {
    final tableName = _tableName(language);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    _db.execute(
      '''
			UPDATE language_tables
			SET word_count = (SELECT COUNT(1) FROM $tableName),
					updated_at = ?
			WHERE language_code = ?;
			''',
      [now, _languageCode(language)],
    );
  }

  /// Converts various time formats to milliseconds since epoch.
  int? _toEpochMillis(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is DateTime) {
      return value.toUtc().millisecondsSinceEpoch;
    }
    if (value is String) {
      return DateTime.parse(value).toUtc().millisecondsSinceEpoch;
    }
    throw ArgumentError('Unsupported time value: $value');
  }

  /// Converts various time formats to milliseconds since epoch.
  /// Throws [ArgumentError] if the value is null.
  int _requireEpochMillis(Object? value) {
    final millis = _toEpochMillis(value);
    if (millis == null) {
      throw ArgumentError('Time value must not be null');
    }
    return millis;
  }

  /// Converts a time value to ISO 8601 string format.
  String _toIsoString(Object value) {
    if (value is String) {
      return value;
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
        isUtc: true,
      ).toIso8601String();
    }
    throw ArgumentError('Unsupported time value: $value');
  }

  String? _toNullableIsoString(Object? value) {
    if (value == null) {
      return null;
    }
    return _toIsoString(value);
  }
}
