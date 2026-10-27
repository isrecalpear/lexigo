import 'package:lexigo/backend/database/interface.dart';

// Package imports:
import 'package:fsrs/fsrs.dart';

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/utils/app_logger.dart';

import 'package:drift/drift.dart';
import 'package:lexigo/utils/settings.dart';

class WordManager {
  final _database = Database();
  Settings get _settings => SettingsStore.instance.settings;

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

  Future<void> insertWord(Word word) async {
    AppLogger.info('Inserting word: ${word.originalWord}');
    final now = DateTime.now();
    final companion = wordToCompanion(word, updatedAt: now);
    await _database.into(_database.wordTable).insert(companion);
    AppLogger.info('Inserted word successfully: ${word.originalWord}');
  }

  /// Inserts [words] in chunks inside a single transaction.
  ///
  /// Chunking keeps the working set small and lets callers report progress
  /// between batches, while the surrounding transaction keeps an import
  /// all-or-nothing. [onProgress] receives the processed and total counts after
  /// every chunk.
  Future<void> insertWords(
    List<Word> words, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (words.isEmpty) {
      AppLogger.info('No words to insert');
      return;
    }
    const int chunkSize = 200;
    final int total = words.length;
    final now = DateTime.now();
    AppLogger.info('Start to insert $total words');
    await _database.transaction(() async {
      for (int start = 0; start < total; start += chunkSize) {
        final int end = start + chunkSize < total ? start + chunkSize : total;
        final companions = <WordTableCompanion>[
          for (final word in words.sublist(start, end))
            wordToCompanion(word, updatedAt: now),
        ];
        await _database.batch((batch) {
          batch.insertAll(
            _database.wordTable,
            companions,
            mode: InsertMode.insertOrReplace,
          );
        });
        onProgress?.call(end, total);
      }
    });
    AppLogger.info('Inserted $total words successfully');
  }

  /// Updates the word row identified by `cardId`.
  ///
  /// Returns the number of affected rows. A result of `0` means the word is not
  /// persisted (for example the in-memory fallback word shown for an empty
  /// database), which callers use to avoid writing orphan data.
  Future<int> updateWord(Word word) async {
    AppLogger.info('Updating word: ${word.originalWord}');
    final companion = wordToCompanion(word, updatedAt: DateTime.now());
    final statement = _database.update(_database.wordTable)
      ..where((t) => t.cardId.equals(companion.cardId.value));
    final rows = await statement.write(companion);
    AppLogger.info(
      'Updated word successfully: ${word.originalWord} ($rows rows)',
    );
    return rows;
  }

  Future<void> updateWords(List<Word> words) async {
    AppLogger.info('Start to update multiple words');
    final updatedAt = DateTime.now();
    await _database.transaction(() async {
      for (final word in words) {
        final companion = wordToCompanion(word, updatedAt: updatedAt);
        final statement = _database.update(_database.wordTable)
          ..where((t) => t.cardId.equals(companion.cardId.value));
        await statement.write(companion);
        AppLogger.info('Updated word successfully: ${word.originalWord}');
      }
    });
    AppLogger.info('Multiple words updated');
  }

  Future<void> deleteWordsByCardId(List<int> cardIds) async {
    AppLogger.info('Deleting ${cardIds.length} words by cardIds: $cardIds');
    final statement = _database.delete(_database.wordTable)
      ..where((t) => t.cardId.isIn(cardIds));
    final rows = await statement.go();
    AppLogger.info('Deleted $rows words successfully');
  }

  Future<Word?> getWordByCardId(int cardId) async {
    AppLogger.info('Getting word by cardId: $cardId');
    final result = await (_database.select(
      _database.wordTable,
    )..where((t) => t.cardId.equals(cardId))).getSingleOrNull();

    if (result == null) {
      AppLogger.info('No word found for cardId: $cardId');
      return null;
    }
    AppLogger.info('Found word: ${result.originalWord}');
    return tableDataToWord(result);
  }

  /// Returns the words for [languageCode].
  ///
  /// When [limit] is omitted every word is returned, so callers such as the
  /// word list and the import de-duplication see the whole table instead of a
  /// silently truncated slice.
  Future<List<Word>> getWords(
    LanguageCode languageCode, {
    int? limit,
    int? offset,
  }) async {
    AppLogger.info(
      'Getting words for $languageCode, limit: ${limit ?? 'all'}, offset: $offset',
    );
    final query = _database.select(_database.wordTable)
      ..where((t) => t.languageCode.equals(languageCode.name))
      ..orderBy([(t) => OrderingTerm(expression: t.id)]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    final results = await query.get();

    final words = <Word>[];
    if (results.isEmpty) {
      AppLogger.info('No words found for $languageCode');
      return words;
    }
    for (final r in results) {
      words.add(tableDataToWord(r));
    }
    AppLogger.info('Retrieved ${words.length} words for $languageCode');
    return words;
  }

  /// Returns the identity keys (`originalWord||bookId||unitId`) of every word
  /// in [languageCode].
  ///
  /// Only the three columns that take part in import de-duplication are read,
  /// which keeps this cheap even for large vocabulary tables.
  Future<Set<String>> getWordIdentityKeys(LanguageCode languageCode) async {
    final query = _database.selectOnly(_database.wordTable)
      ..addColumns([
        _database.wordTable.originalWord,
        _database.wordTable.bookId,
        _database.wordTable.unitId,
      ])
      ..where(_database.wordTable.languageCode.equals(languageCode.name));
    final rows = await query.get();
    return rows
        .map(
          (row) =>
              '${row.read(_database.wordTable.originalWord) ?? ''}'
              '||${row.read(_database.wordTable.bookId) ?? ''}'
              '||${row.read(_database.wordTable.unitId) ?? ''}',
        )
        .toSet();
  }

  Future<Word?> getRandomWord(LanguageCode languageCode) async {
    AppLogger.info('Getting random word for $languageCode');
    final result =
        await (_database.select(_database.wordTable)
              ..where((t) => t.languageCode.equals(languageCode.name))
              ..orderBy([
                (t) => OrderingTerm(expression: CustomExpression('RANDOM()')),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (result == null) {
      AppLogger.info('No random word found for $languageCode');
      return null;
    }
    AppLogger.info('Random word found: ${result.originalWord}');
    return tableDataToWord(result);
  }

  Future<Word?> getNextReviewWord([LanguageCode? languageCode]) async {
    DateTime currentTime = DateTime.now();
    LanguageCode lang = languageCode ?? _settings.learningLanguage;
    AppLogger.info('Getting next review word for $lang');
    final result =
        await (_database.select(_database.wordTable)
              ..where(
                (t) => Expression.and([
                  t.cardDueTime.isSmallerThanValue(currentTime),
                  t.languageCode.equals(lang.name),
                ]),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.cardDueTime)])
              ..limit(1))
            .getSingleOrNull();

    if (result == null) {
      AppLogger.info('No pending review words for $lang');
      return null;
    }
    AppLogger.info('Next review word: ${result.originalWord}');
    return tableDataToWord(result);
  }

  Future<Word?> getNextUnlearnedWord([LanguageCode? languageCode]) async {
    LanguageCode lang = languageCode ?? _settings.learningLanguage;
    final result =
        await (_database.select(_database.wordTable)
              ..where(
                (t) => Expression.and([
                  t.cardLastReviewTime.isNull(),
                  t.languageCode.equals(lang.name),
                ]),
              )
              ..orderBy([
                (t) => OrderingTerm(expression: CustomExpression('RANDOM()')),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (result == null) {
      AppLogger.info('No pending unlearned word for $lang');
      return null;
    }
    AppLogger.info('Next word: ${result.originalWord}');
    return tableDataToWord(result);
  }

  /// Escape character used to treat user input literally in `LIKE` patterns.
  static const String _likeEscapeChar = '\\';

  /// Escapes `LIKE` wildcards in [input] so it is matched as literal text.
  static String _escapeLikePattern(String input) => input
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');

  /// Searches [languageCode] words for [parts] in every text column.
  ///
  /// Matches are case-insensitive substrings (the query is wrapped in `%`), and
  /// they never leak into other languages.
  Future<List<Word>> searchWords(
    LanguageCode languageCode,
    String parts, {
    int limit = 20,
  }) async {
    final String query = parts.trim();
    if (query.isEmpty) {
      return <Word>[];
    }
    final String pattern = '%${_escapeLikePattern(query)}%';
    AppLogger.info(
      'Searching words for $languageCode with query: "$query", limit: $limit',
    );
    final results =
        await (_database.select(_database.wordTable)
              ..where(
                (t) => Expression.and([
                  t.languageCode.equals(languageCode.name),
                  Expression.or([
                    t.originalWord.like(pattern, escapeChar: _likeEscapeChar),
                    t.originalTranslation.like(
                      pattern,
                      escapeChar: _likeEscapeChar,
                    ),
                    t.exampleSentence.like(
                      pattern,
                      escapeChar: _likeEscapeChar,
                    ),
                    t.exampleTranslation.like(
                      pattern,
                      escapeChar: _likeEscapeChar,
                    ),
                  ]),
                ]),
              )
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.cardDueTime,
                  mode: OrderingMode.asc,
                ),
              ])
              ..limit(limit))
            .get();
    final words = <Word>[];
    if (results.isEmpty) {
      AppLogger.info('No search results for "$query"');
      return words;
    }
    for (final r in results) {
      words.add(tableDataToWord(r));
    }
    AppLogger.info('Found ${words.length} results for "$query"');
    return words;
  }

  /// Reviews [word] with [rating], persisting the updated card and a history
  /// row.
  ///
  /// Returns the word carrying the updated FSRS card so callers can keep their
  /// in-memory copy in sync with the scheduler, or `null` when the word is not
  /// persisted (e.g. the per-language fallback word).
  Future<Word?> reviewWord(
    Word word,
    Rating rating,
    int? reviewDuration,
  ) async {
    final card_ = word.card;
    final (:card, :reviewLog) = scheduler.reviewCard(
      card_,
      rating,
      reviewDateTime: DateTime.now().toUtc(),
      reviewDuration: reviewDuration,
    );
    final updatedWord = Word(
      originalWord: word.originalWord,
      originalTranslation: word.originalTranslation,
      exampleSentence: word.exampleSentence,
      exampleTranslation: word.exampleTranslation,
      sourceLanguageCode: word.sourceLanguageCode,
      card: card,
      unitID: word.unitID,
      bookID: word.bookID,
    );
    final int updatedRows = await updateWord(updatedWord);
    if (updatedRows == 0) {
      // Fallback/demo words are never persisted, so reviewing them must not
      // create history rows pointing at a non-existent card.
      AppLogger.warning(
        'Skipping review persistence for unpersisted word: ${word.originalWord}',
      );
      return null;
    }
    await insertReviewLog(reviewLog);
    AppLogger.info('Review recorded for: ${word.originalWord} ($rating)');
    return updatedWord;
  }

  /// Inserts [reviewLog] into the learning history table.
  Future<void> insertReviewLog(ReviewLog reviewLog) async {
    AppLogger.info('Start to insert review log ${reviewLog.cardId}');
    final companion = reviewLogToCompanion(reviewLog);
    await _database
        .into(_database.wordLearningHistoryTable)
        .insert(companion, mode: InsertMode.insertOrReplace);
    AppLogger.info('Inserted review log successfully: ${reviewLog.cardId}');
  }

  /// Inserts [reviewLogs] in a single batch.
  Future<void> insertReviewLogs(Iterable<ReviewLog> reviewLogs) async {
    AppLogger.info('Start to insert ${reviewLogs.length} review logs');
    final companions = <WordLearningHistoryTableCompanion>[
      for (final reviewLog in reviewLogs) reviewLogToCompanion(reviewLog),
    ];
    await _database.batch((batch) {
      batch.insertAll(
        _database.wordLearningHistoryTable,
        companions,
        mode: InsertMode.insertOrReplace,
      );
    });
    AppLogger.info('Inserted ${reviewLogs.length} review logs successfully');
  }

  /// Returns the stored review logs, limited to [word] when it is provided.
  Future<List<ReviewLog>> getReviewLogs([Word? word]) async {
    late List<WordLearningHistoryTableData> learningHistoryRows;
    if (word != null) {
      final card = word.card;
      learningHistoryRows = await (_database.select(
        _database.wordLearningHistoryTable,
      )..where((t) => t.cardId.equals(card.cardId))).get();
    } else {
      learningHistoryRows = await _database
          .select(_database.wordLearningHistoryTable)
          .get();
    }
    final reviewLogs = <ReviewLog>[];
    for (final row in learningHistoryRows) {
      reviewLogs.add(_tableDataToReviewLog(row));
    }
    return reviewLogs;
  }

  Future<int> reviewPendingWordsCount([LanguageCode? languageCode]) async {
    final lang = languageCode ?? _settings.learningLanguage;
    AppLogger.info('Counting pending review words for $lang');
    final countExpr = _database.wordTable.id.count();
    final result =
        await (_database.selectOnly(_database.wordTable)
              ..addColumns([countExpr])
              ..where(
                Expression.and([
                  _database.wordTable.cardDueTime.isSmallerThanValue(
                    DateTime.now(),
                  ),
                  _database.wordTable.languageCode.equals(lang.name),
                ]),
              ))
            .getSingle();
    final count = result.read(countExpr) ?? 0;
    AppLogger.info('Pending review words count for $lang: $count');
    return count;
  }

  /// Builds the insertable row for [word].
  WordTableCompanion wordToCompanion(
    Word word, {
    DateTime? createdAt,
    required DateTime updatedAt,
  }) {
    final wordCard = word.card;
    return WordTableCompanion.insert(
      languageCode: word.sourceLanguageCode.name,
      originalWord: word.originalWord,
      originalTranslation: word.originalTranslation,
      exampleSentence: word.exampleSentence,
      exampleTranslation: word.exampleTranslation,
      unitId: Value(word.unitID),
      bookId: Value(word.bookID),
      cardId: wordCard.cardId,
      cardState: wordCard.state.value,
      cardStep: wordCard.step ?? 0,

      /// ⬆️ The Card will generate a step. So, just in case.
      cardStability: Value(wordCard.stability),
      cardDifficulty: Value(wordCard.difficulty),
      cardDueTime: wordCard.due,
      cardLastReviewTime: Value(wordCard.lastReview),
      createdAtTime: createdAt ?? DateTime.now(),
      updatedAtTime: updatedAt,
    );
  }

  Word tableDataToWord(WordTableData wordTableData) {
    Card card = Card.fromMap({
      'cardId': wordTableData.cardId,
      'state': wordTableData.cardState,
      'step': wordTableData.cardStep,
      'stability': wordTableData.cardStability,
      'difficulty': wordTableData.cardDifficulty,
      'due': wordTableData.cardDueTime.toUtc().toIso8601String(),
      'lastReview': wordTableData.cardLastReviewTime?.toUtc().toIso8601String(),
    });
    Word word = Word(
      originalWord: wordTableData.originalWord,
      originalTranslation: wordTableData.originalTranslation,
      exampleSentence: wordTableData.exampleSentence,
      exampleTranslation: wordTableData.exampleTranslation,
      sourceLanguageCode: LanguageCode.values.byName(
        wordTableData.languageCode,
      ),
      card: card,
      unitID: wordTableData.unitId,
      bookID: wordTableData.bookId,
    );
    return word;
  }

  WordLearningHistoryTableCompanion reviewLogToCompanion(ReviewLog reviewLog) {
    return WordLearningHistoryTableCompanion(
      cardId: Value(reviewLog.cardId),
      rating: Value(reviewLog.rating),
      reviewDateTime: Value(reviewLog.reviewDateTime),
      reviewDuration: Value(reviewLog.reviewDuration),
    );
  }

  ReviewLog _tableDataToReviewLog(WordLearningHistoryTableData tableData) {
    return (ReviewLog(
      cardId: tableData.cardId,
      rating: tableData.rating,
      reviewDateTime: tableData.reviewDateTime,
      reviewDuration: tableData.reviewDuration,
    ));
  }
}
