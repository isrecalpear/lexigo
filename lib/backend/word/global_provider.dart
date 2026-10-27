library;

import 'package:flutter/foundation.dart';

import 'package:lexigo/backend/word.dart';
import 'package:lexigo/utils/settings.dart';
import 'package:lexigo/backend/word/manager.dart';
import 'package:fsrs/fsrs.dart';
import 'package:lexigo/backend/word/fallback.dart';

class WordProvider extends ChangeNotifier {
  final _wordManager = WordManager();

  Word? _currentWord;
  bool _isFallbackWord = true;

  /// Creates a provider that already has a displayable word.
  ///
  /// The per-language fallback word is installed immediately so the study page
  /// never has to render a `null` word while the database is being opened. The
  /// next [loadRandomWord] replaces it with a real word when one exists.
  WordProvider() {
    _currentWord = _createFallbackWord();
  }

  Word? get currentWord => _currentWord;

  /// Whether [currentWord] is the in-memory placeholder word shown when the
  /// current learning language has no words in the database.
  ///
  /// Placeholder words are never persisted, so callers use this flag to avoid
  /// starting a learning session with one.
  bool get isFallbackWord => _isFallbackWord;

  String get heroTag =>
      _currentWord != null ? 'word_${_currentWord!.originalWord}' : '';

  Settings get _settings => SettingsStore.instance.settings;

  void updateWord(Word word) {
    _currentWord = word;
    _isFallbackWord = false;
    notifyListeners();
  }

  /// Loads a random word for the current learning language.
  ///
  /// Returns the loaded word, or `null` when the language has no words yet.
  /// On an empty library the placeholder word is kept on screen: publishing a
  /// `null` word would blank the study page for a frame, making a swipe or a
  /// "start learning" tap look like the page is refreshing.
  Future<Word?> loadRandomWord() async {
    final Word? word = await _wordManager.getRandomWord(
      _settings.learningLanguage,
    );
    if (word == null) {
      _showFallbackWord();
      return null;
    }
    _currentWord = word;
    _isFallbackWord = false;
    notifyListeners();
    return word;
  }

  Future<void> nextReviewWord() async {
    final word = await _wordManager.getNextReviewWord(
      _settings.learningLanguage,
    );
    _currentWord = word;
    _isFallbackWord = false;
    notifyListeners();
  }

  Future<void> reviewWord(Word word, Rating rating, int? reviewDuration) async {
    await _wordManager.reviewWord(word, rating, reviewDuration);
  }

  /// Replaces [currentWord] with the placeholder word for the current language.
  ///
  /// Calling this while that placeholder is already displayed is a no-op, so
  /// listeners are not notified (and nothing rebuilds) for an unchanged word.
  void setFallbackWord() => _showFallbackWord();

  void _showFallbackWord() {
    final LanguageCode language = _settings.learningLanguage;
    if (_isFallbackWord && _currentWord?.sourceLanguageCode == language) {
      return;
    }
    _currentWord = _createFallbackWord(language);
    _isFallbackWord = true;
    notifyListeners();
  }

  Word _createFallbackWord([LanguageCode? languageCode]) {
    final LanguageCode language = languageCode ?? _settings.learningLanguage;
    final factory = fallbackWordFactories[language];
    if (factory == null) {
      throw ArgumentError(
        'No fallback word configured for language: $language',
      );
    }
    return factory();
  }
}
