/// Centralized word state provider for the learning flow.
///
/// Manages the currently displayed word and its derived Hero animation tag.
/// All pages that display [WordCard] in the learning flow (StartPage,
/// LearningPage, LearningSummarizePage) read from this single source of truth,
/// ensuring Hero tags are always consistent across page transitions.
library;

import 'package:flutter/foundation.dart';

import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/orm/word_repository.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/settings.dart';

/// Provides the current word and its Hero tag to all learning-flow pages.
///
/// Extends [ChangeNotifier] so that widgets can listen for changes via
/// [addListener] / [removeListener] or [ListenableBuilder].
class WordProvider extends ChangeNotifier {
  Word? _currentWord;

  /// The word currently displayed in the learning flow, or `null` if not yet
  /// loaded.
  Word? get currentWord => _currentWord;

  /// The Hero animation tag derived from the current word.
  ///
  /// Format: `'word_${originalWord}'`.  Returns an empty string when
  /// [currentWord] is `null`.
  String get heroTag =>
      _currentWord != null ? 'word_${_currentWord!.originalWord}' : '';

  /// Shortcut to the current [Settings] instance.
  Settings get _settings => SettingsStore.instance.settings;

  /// Replaces the current word and notifies listeners.
  void updateWord(Word word) {
    _currentWord = word;
    AppLogger.debug('WordProvider updated: ${word.originalWord}');
    notifyListeners();
  }

  /// Loads a random word from the repository and notifies listeners.
  Future<void> loadRandomWord() async {
    final repo = await WordRepository.open();
    final word = await repo.getRandomWord(_settings.learningLanguage,);
    _currentWord = word;
    AppLogger.debug('WordProvider loaded random word: ${word.originalWord}');
    notifyListeners();
  }

  /// Loads the next word due for review based on FSRS scheduling.
  ///
  /// TODO: Implement actual review word loading logic:
  /// - Query the database for the next due review card
  /// - Update _currentWord with the result
  /// - Handle case when no review cards are available (return to start page)
  Future<void> nextReviewWord() async {
    // TODO: Replace with actual review word loading
    // final repo = await WordRepository.open();
    // final word = await repo.getReviewWord(_settings.learningLanguage);
    // if (word != null) {
    //   _currentWord = word;
    //   AppLogger.debug('WordProvider loaded review word: ${word.originalWord}');
    // }
    notifyListeners();
  }
}
