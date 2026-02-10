// Package imports:
import 'package:fsrs/fsrs.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'database.dart';

class WordDao {
  WordDao._(this._db);

  final sqlite.Database _db;

  static Future<WordDao> open() async {
    final db = await Database.getInstance();
    return WordDao._(db);
  }

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

  Future<int> deleteAll(LanguageCode language) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    _db.execute('DELETE FROM $tableName;');
    final count = _changes();
    AppLogger.info('Cleared word table: $tableName, deleted count: $count');
    _refreshWordCount(language);
    return count;
  }

  Future<Word?> getWordByCardId(LanguageCode language, int cardId) async {
    _ensureTable(language);
    final tableName = _tableName(language);
    final result = _db.select(
      'SELECT * FROM $tableName WHERE card_id = ? LIMIT 1;',
      [cardId],
    );
    if (result.isEmpty) {
      return null;
    }
    AppLogger.debug('Retrieved word successfully: cardId=$cardId');
    return _fromRow(result.first, language);
  }

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

  Future<List<Map<String, Object?>>> getLanguageSummary() async {
    final result = _db.select('SELECT * FROM language_tables;');
    final columns = result.columnNames;
    return result
        .map((row) => {for (final col in columns) col: row[col]})
        .toList();
  }

  void _ensureTable(LanguageCode language) {
    final languageCode = _languageCode(language);
    Database.ensureLanguageTable(_db, languageCode);
  }

  String _languageCode(LanguageCode language) {
    return language.name;
  }

  String _tableName(LanguageCode language) {
    return Database.tableNameForLanguage(_languageCode(language));
  }

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

  int _changes() {
    final result = _db.select('SELECT changes() AS count;');
    return result.first['count'] as int;
  }

  List<List<int>> _chunk(List<int> values, int size) {
    final chunks = <List<int>>[];
    for (var i = 0; i < values.length; i += size) {
      chunks.add(
        values.sublist(i, i + size > values.length ? values.length : i + size),
      );
    }
    return chunks;
  }

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

  int _requireEpochMillis(Object? value) {
    final millis = _toEpochMillis(value);
    if (millis == null) {
      throw ArgumentError('Time value must not be null');
    }
    return millis;
  }

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
