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
    final companion = await _wordToCompanion(word, updatedAt: now);
    await _database.into(_database.wordTable).insert(companion);
    AppLogger.info('Inserted word successfully: ${word.originalWord}');
  }

  Future<void> insertWords(List<Word> words) async {
    AppLogger.info('Start to insert ${words.length} words');
    final now = DateTime.now();
    final companions = <WordTableCompanion>[];
    for (final word in words) {
      companions.add(await _wordToCompanion(word, updatedAt: now));
    }
    await _database.batch((batch) {
      batch.insertAll(
        _database.wordTable,
        companions,
        mode: InsertMode.insertOrReplace,
      );
    });
    AppLogger.info('Inserted ${words.length} words successfully');
  }

  Future<void> updateWord(Word word) async {
    AppLogger.info('Updating word: ${word.originalWord}');
    final companion = await _wordToCompanion(word, updatedAt: DateTime.now());
    _database.update(_database.wordTable)
      ..where((t) => t.cardId.equals(companion.cardId.value))
      ..write(companion);
    AppLogger.info('Updated word successfully: ${word.originalWord}');
  }

  Future<void> updateWords(List<Word> words) async {
    AppLogger.info('Start to update multiple words');
    final updatedAt = DateTime.now();
    for (final word in words) {
      final companion = await _wordToCompanion(word, updatedAt: updatedAt);
      _database.update(_database.wordTable)
        ..where((t) => t.cardId.equals(companion.cardId.value))
        ..write(companion);
      AppLogger.info('Updated word successfully: ${word.originalWord}');
    }
    AppLogger.info('Multiple words updated');
  }

  Future<void> deleteWordsByCardId(List<int> cardIds) async {
    AppLogger.info('Deleting ${cardIds.length} words by cardIds: $cardIds');
    (_database.delete(
      _database.wordTable,
    )..where((t) => t.cardId.isIn(cardIds))).go();
    AppLogger.info('Deleted words successfully');
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
    return _tableDataToWord(result);
  }

  Future<List<Word>> getWords(
    LanguageCode languageCode, {
    int? limit,
    int? offset,
  }) async {
    final lim = limit ?? 64;
    AppLogger.info(
      'Getting words for $languageCode, limit: $lim, offset: $offset',
    );
    final results =
        await (_database.select(_database.wordTable)
              ..where((t) => t.languageCode.equals(languageCode.name))
              ..limit(lim, offset: offset)
              ..orderBy([(t) => OrderingTerm(expression: t.id)]))
            .get();

    final words = <Word>[];
    if (results.isEmpty) {
      AppLogger.info('No words found for $languageCode');
      return words;
    }
    for (final r in results) {
      words.add(_tableDataToWord(r));
    }
    AppLogger.info('Retrieved ${words.length} words for $languageCode');
    return words;
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
    return _tableDataToWord(result);
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
    return _tableDataToWord(result);
  }

  Future<List<Word>> searchWords(
    LanguageCode languageCode,
    String parts, {
    int limit = 20,
  }) async {
    AppLogger.info(
      'Searching words for $languageCode with query: "$parts", limit: $limit',
    );
    final results =
        await (_database.select(_database.wordTable)
              ..where(
                (t) => Expression.or([
                  t.originalWord.like(parts),
                  t.originalTranslation.like(parts),
                  t.exampleSentence.like(parts),
                  t.exampleTranslation.like(parts),
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
      AppLogger.info('No search results for "$parts"');
      return words;
    }
    for (final r in results) {
      words.add(_tableDataToWord(r));
    }
    AppLogger.info('Found ${words.length} results for "$parts"');
    return words;
  }

  Future<void> reviewWord(Word word, Rating rating, int? reviewDuration) async {
    final card_ = await word.card;
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
      card: Future.value(card),
      unitID: word.unitID,
      bookID: word.bookID,
    );
    await updateWord(updatedWord);

    final companion = WordLearningHistoryTableCompanion(
      cardId: Value(reviewLog.cardId),
      rating: Value(reviewLog.rating),
      reviewDateTime: Value(reviewLog.reviewDateTime),
      reviewDuration: Value(reviewLog.reviewDuration),
    );
    _database.into(_database.wordLearningHistoryTable).insert(companion);
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

  Future<WordTableCompanion> _wordToCompanion(
    Word word, {
    DateTime? createdAt,
    required DateTime updatedAt,
  }) async {
    final wordCard = await word.card;
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

  Word _tableDataToWord(WordTableData wordTableData) {
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
      card: Future.value(card),
      unitID: wordTableData.unitId,
      bookID: wordTableData.bookId,
    );
    return word;
  }
}
