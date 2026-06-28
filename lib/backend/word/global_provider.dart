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

  Word? get currentWord => _currentWord;

  String get heroTag =>
      _currentWord != null ? 'word_${_currentWord!.originalWord}' : '';

  Settings get _settings => SettingsStore.instance.settings;

  bool isFallbackWord = false;

  void updateWord(Word word) {
    _currentWord = word;
    isFallbackWord = false;
    notifyListeners();
  }

  Future<void> loadRandomWord() async {
    final word = await _wordManager.getRandomWord(_settings.learningLanguage);
    _currentWord = word;
    isFallbackWord = false;
    notifyListeners();
  }

  Future<void> nextReviewWord() async {
    final word = await _wordManager.getNextReviewWord(
      _settings.learningLanguage,
    );
    _currentWord = word;
    isFallbackWord = false;
    notifyListeners();
  }

  Future<void> reviewWord(Word word, Rating rating) async {
    await _wordManager.reviewWord(word, rating);
  }

  void setFallbackWord() {
    final factory = fallbackWordFactories[_settings.learningLanguage];
    if (factory == null) {
      throw ArgumentError(
        'No fallback word configured for language: ${_settings.learningLanguage}',
      );
    }
    isFallbackWord = true;
    _currentWord = factory();
    notifyListeners();
  }
}
