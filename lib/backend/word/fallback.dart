// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:fsrs/fsrs.dart';

/// Placeholder card for words shown before the database has content.
///
/// Fallback words are never persisted, so a fixed, non-conflicting (negative)
/// card id is enough. A fresh instance per word keeps scheduler mutations
/// isolated between the cards.
Card _fallbackCard() => Card(cardId: -1);

final Map<LanguageCode, Word Function()> fallbackWordFactories = {
  LanguageCode.ru: () => Word(
    originalWord: "\u043B\u044E\u0431\u0438\u0442\u044C",
    originalTranslation: "\u7231",
    exampleSentence:
        "\u042F \u043B\u044E\u0431\u043B\u044E \u0442\u0435\u0431\u044F.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ru,
    card: _fallbackCard(),
  ),
  LanguageCode.ko: () => Word(
    originalWord: "\uC0AC\uB791\uD558\uB2E4",
    originalTranslation: "\u7231",
    exampleSentence: "\uC0AC\uB791\uD574\uC694.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.ko,
    card: _fallbackCard(),
  ),
  LanguageCode.en: () => Word(
    originalWord: "Love",
    originalTranslation: "\u7231",
    exampleSentence: "I love you.",
    exampleTranslation: "\u6211\u7231\u4F60\u3002",
    sourceLanguageCode: LanguageCode.en,
    card: _fallbackCard(),
  ),
};
