/// Word data provider and FSRS scheduler management.
///
/// This file provides word retrieval methods and FSRS spaced repetition scheduling.
/// It handles loading words from the database, managing fallback words, and
/// updating card states after reviews.

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/datas/orm/word_dao.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/pages/my_page/word_management/word_edit_page.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Provides word loading and FSRS scheduling operations.
class WordProvider {
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
  static final fsrs.Scheduler scheduler = fsrs.Scheduler(
    parameters: _schedulerParameters,
    desiredRetention: _schedulerDesiredRetention,
    learningSteps: _schedulerLearningSteps,
    relearningSteps: _schedulerRelearningSteps,
    maximumInterval: _schedulerMaximumInterval,
    enableFuzzing: _schedulerEnableFuzzing,
  );

  /// Returns a fallback word for the specified language when database is empty.
  static Word _fallbackWordFor(LanguageCode language) {
    switch (language) {
      case LanguageCode.ru:
        return Word(
          originalWord: "любить",
          translation: "爱",
          originalExample: "Я люблю тебя.",
          exampleTranslation: "我爱你。",
          sourceLanguageCode: LanguageCode.ru,
          card: fsrs.Card.create(),
        );
      case LanguageCode.ko:
        return Word(
          originalWord: "사랑하다",
          translation: "爱",
          originalExample: "사랑해요.",
          exampleTranslation: "我爱你。",
          sourceLanguageCode: LanguageCode.ko,
          card: fsrs.Card.create(),
        );
      case LanguageCode.en:
        return Word(
          originalWord: "Love",
          translation: "爱",
          originalExample: "I love you.",
          exampleTranslation: "我爱你。",
          sourceLanguageCode: LanguageCode.en,
          card: fsrs.Card.create(),
        );
    }
  }

  /// Retrieves a random word for the specified language or all languages if null.
  ///
  /// First tries to load from database. If no words exist, returns a fallback
  /// word in the selected language.
  Future<Word> getWord({LanguageCode? language}) async {
    try {
      final dao = await WordDao.open();
      final random = Random();

      // TODO: Change the logic, select a word that user don't know, not a random word.
      if (language != null) {
        final words = await dao.getWords(language);
        if (words.isNotEmpty) {
          final word = words[random.nextInt(words.length)];
          AppLogger.debug('Get word from database: ${word.originalWord}');
          return word;
        }
      } else {
        final allWords = <Word>[];
        for (final lang in LanguageCode.values) {
          final words = await dao.getWords(lang);
          allWords.addAll(words);
        }
        if (allWords.isNotEmpty) {
          final word = allWords[random.nextInt(allWords.length)];
          AppLogger.debug('Get word from database: ${word.originalWord}');
          return word;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get word from database',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final fallbackLanguage = language ?? LanguageCode.en;
    AppLogger.warning(
      'No words in database, returning fallback word for $fallbackLanguage',
    );
    return _fallbackWordFor(fallbackLanguage);
  }

  /// Retrieves the next word due for review in the specified language.
  ///
  /// Returns null if no review words are available.
  Future<Word?> getReviewWord({required LanguageCode language}) async {
    try {
      final dao = await WordDao.open();
      final dueCard = await dao.getReviewWord(language);
      if (dueCard != null) {
        AppLogger.debug(
          'Get review word from database: ${dueCard.originalWord}',
        );
        return dueCard;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get review word from database',
        error: e,
        stackTrace: stackTrace,
      );
    }
    AppLogger.warning('No review words in database for language: $language');
    return null;
  }

  /// Processes a word review with the given rating.
  ///
  /// Updates the FSRS card state based on the rating and saves to database.
  /// Logs the scheduling result for debugging.
  Future<void> reviewWord(Word word, fsrs.Rating rating) async {
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

      final dao = await WordDao.open();
      await dao.updateWord(word.sourceLanguageCode, updatedWord);

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

  /// Marks a word as known (implementation pending).
  Future<Word?> signAsKnown(BuildContext context, Word word) async {
    // TODO: Implement signAsKnown functionality
    AppLogger.info('Marking as known: ${word.originalWord}');
    return null;
  }

  /// Opens the word edit dialog to correct/update a word.
  ///
  /// Returns the updated word if changes were made, or null if cancelled.
  Future<Word?> signAsWrong(BuildContext context, Word word) async {
    final card = await word.card;
    if (!context.mounted) return null;
    final updated = await Navigator.push<Word>(
      context,
      MaterialPageRoute(
        builder: (context) => WordEditPage(word: word, card: card),
      ),
    );
    return updated;
  }
}
