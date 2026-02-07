import 'dart:math';

import 'package:fsrs/fsrs.dart';
import 'package:lexigo/datas/orms/words.dart';
import 'package:lexigo/datas/word.dart';
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

  static final Scheduler scheduler = Scheduler(
    parameters: _schedulerParameters,
    desiredRetention: _schedulerDesiredRetention,
    learningSteps: _schedulerLearningSteps,
    relearningSteps: _schedulerRelearningSteps,
    maximumInterval: _schedulerMaximumInterval,
    enableFuzzing: _schedulerEnableFuzzing,
  );

  static final Word _staticWord =  Word(
    originalWord: "Love",
    translation: "爱",
    originalExample: "I love you.",
    exampleTranslation: "我爱你。",
    sourceLanguageCode: LanguageCode.en,
    card: Card.create(),
  );

  Future<Word> getWord({LanguageCode? language}) async {
    try {
      final dao = await WordDao.open();
      final random = Random();

      if (language != null) {
        final words = await dao.getWords(language);
        if (words.isNotEmpty) {
          final word = words[random.nextInt(words.length)];
          AppLogger.debug('从数据库获取单词: ${word.originalWord}');
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
          AppLogger.debug('从数据库获取单词: ${word.originalWord}');
          return word;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('从数据库获取单词失败', error: e, stackTrace: stackTrace);
    }

    AppLogger.warning('数据库暂无单词，返回静态单词');
    return _staticWord;
  }

  bool signAsKnown(Word word) {
    AppLogger.info('标记为熟知: ${word.originalWord}');
    return true;
  }

  bool signAsWrong(Word word) {
    AppLogger.info('纠错单词: ${word.originalWord}');
    return true;
  }

}
