// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:fsrs/fsrs.dart';

final Map<LanguageCode, Word Function()> _fallbackWordFactories = {
  LanguageCode.ru: () => Word(
    originalWord: "\u043B\u044E\u0431\u0438\u0442\u044C",
    translation: "\u7231",
    originalExample:
        "\u042F \u043B\u044E\u0431\u043B\u044E \u0442\u0435\u0431\u044F.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ru,
    card: Card.create(),
  ),
  LanguageCode.ko: () => Word(
    originalWord: "\uC0AC\uB791\uD558\uB2E4",
    translation: "\u7231",
    originalExample: "\uC0AC\uB791\uD574\uC694.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ko,
    card: Card.create(),
  ),
  LanguageCode.en: () => Word(
    originalWord: "Love",
    translation: "\u7231",
    originalExample: "I love you.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.en,
    card: Card.create(),
  ),
};

/// Returns a fallback word for the specified language when database is empty.
Word fallbackWordFor(LanguageCode language) {
  final factory = _fallbackWordFactories[language];
  if (factory == null) {
    throw ArgumentError('No fallback word configured for language: $language');
  }
  return factory();
}
