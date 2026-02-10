// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/datas/orm/words.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/pages/my_page/word_management/word_edit_page.dart';
import 'package:lexigo/utils/app_logger.dart';

class WordProvider {
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
  static const double _schedulerDesiredRetention = 0.9;
  static const List<Duration> _schedulerLearningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];
  static const List<Duration> _schedulerRelearningSteps = [
    Duration(minutes: 10),
  ];
  static const int _schedulerMaximumInterval = 36500;
  static const bool _schedulerEnableFuzzing = true;

  static final fsrs.Scheduler scheduler = fsrs.Scheduler(
    parameters: _schedulerParameters,
    desiredRetention: _schedulerDesiredRetention,
    learningSteps: _schedulerLearningSteps,
    relearningSteps: _schedulerRelearningSteps,
    maximumInterval: _schedulerMaximumInterval,
    enableFuzzing: _schedulerEnableFuzzing,
  );

  static final Word _staticWord = Word(
    originalWord: "Love",
    translation: "爱",
    originalExample: "I love you.",
    exampleTranslation: "我爱你。",
    sourceLanguageCode: LanguageCode.en,
    card: fsrs.Card.create(),
  );

  Future<Word> getWord({LanguageCode? language}) async {
    try {
      final dao = await WordDao.open();
      final random = Random();

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

    AppLogger.warning('No words in database, returning static word');
    return _staticWord;
  }

  Future<Word?> getReviewWord() async {
    try {
      final dao = await WordDao.open();
      // TODO: read the language code from settings
      final dueCard = await dao.getReviewWord(LanguageCode.en);
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
    AppLogger.warning('No review words in database, returning static word');
    return null;
  }

  bool signAsKnown(BuildContext context, Word word) {
    // TODO: Implement signAsKnown functionality
    AppLogger.info('Marking as known: ${word.originalWord}');
    return true;
  }

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
}
