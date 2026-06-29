// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:fsrs/fsrs.dart';

final Map<LanguageCode, Word Function()> fallbackWordFactories = {
  LanguageCode.ru: () => Word(
    originalWord: "\u043B\u044E\u0431\u0438\u0442\u044C",
    originalTranslation: "\u7231",
    exampleSentence:
        "\u042F \u043B\u044E\u0431\u043B\u044E \u0442\u0435\u0431\u044F.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ru,
    card: Card(cardId: LanguageCode.ru.index * -1),
  ),
  LanguageCode.ko: () => Word(
    originalWord: "\uC0AC\uB791\uD558\uB2E4",
    originalTranslation: "\u7231",
    exampleSentence: "\uC0AC\uB791\uD574\uC694.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ko,
    card: Card(cardId: LanguageCode.ko.index * -1),
  ),
  LanguageCode.en: () => Word(
    originalWord: "Love",
    originalTranslation: "\u7231",
    exampleSentence: "I love you.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.en,
    card: Card(cardId: LanguageCode.en.index * -1),
  ),
};
