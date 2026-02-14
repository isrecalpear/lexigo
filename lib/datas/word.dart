/// Data model for flashcard words.
///
/// This file defines the core Word model and supported language codes.
/// Words contain bilingual content with examples and are associated with
/// FSRS spaced repetition scheduling.

// Package imports:
import 'package:fsrs/fsrs.dart';

/// Supported language codes for learning.
///
/// Based on ISO 639-1 language codes:
/// - [ko]: Korean (한국어)
/// - [ru]: Russian (Русский)
/// - [en]: English
///
/// See https://wikipedia.org/wiki/List_of_ISO_639_language_codes
enum LanguageCode { ko, ru, en }

/// Represents a single flashcard word with bilingual content and examples.
///
/// Each word contains:
/// - The original word/term in the source language
/// - Its translation (typically in Chinese)
/// - An example sentence in the source language
/// - A translation of the example (typically in Chinese)
/// - FSRS card state for spaced repetition scheduling
/// - Associated unit and book IDs for organization
class Word {
  /// The original word/term in the source language.
  final String originalWord;

  /// The translation of the word (typically in Chinese).
  final String translation;

  /// Example sentence containing the word in the source language.
  final String originalExample;

  /// Translation of the example sentence (typically in Chinese).
  final String exampleTranslation;

  /// The source language code of this word.
  final LanguageCode sourceLanguageCode;

  /// FSRS spaced repetition card for scheduling reviews.
  /// Future is used because card data may be loaded asynchronously.
  final Future<Card> card;

  /// Unit ID for organizing words by curriculum units.
  /// Defaults to 'DefaultUnit' if not specified.
  final String unitID;

  /// Book ID for organizing words by source books.
  /// Defaults to 'DefaultBook' if not specified.
  final String bookID;

  /// Creates a new Word instance.
  ///
  /// [unitID] and [bookID] have default values but can be overridden
  /// to organize words into specific curriculum units and source books.
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
