// Package imports:
import 'package:fsrs/fsrs.dart';

// See https://wikipedia.org/wiki/List_of_ISO_639_language_codes
enum LanguageCode { ko, ru, en}

class Word {
  final String originalWord;
  final String translation;
  final String originalExample;
  final String exampleTranslation;
  final LanguageCode sourceLanguageCode;
  final Future<Card> card;
  final String unitID;
  final String bookID;

  Word({
    required this.originalWord,
    required this.translation,
    required this.originalExample,
    required this.exampleTranslation,
    required this.sourceLanguageCode,
    required this.card,
    this.unitID = 'DefaultUnit',
    this.bookID = 'DefaultBook',
  });
}
