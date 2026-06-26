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

  final SettingsStore _settingsStore;

  /// Creates a [WordProvider] that reads the learning language from the given
  /// [settingsStore]. The caller is responsible for keeping the same
  /// [SettingsStore] instance in sync with user preferences.
  WordProvider(this._settingsStore);

  /// Replaces the current word and notifies listeners.
  void updateWord(Word word) {
    _currentWord = word;
    AppLogger.debug('WordProvider updated: ${word.originalWord}');
    notifyListeners();
  }

  /// Loads a random word from the repository for the given [language] and
  /// notifies listeners.
  Future<void> loadRandomWord([LanguageCode? language]) async {
    final Settings settings = _settingsStore.settings;
    final repo = await WordRepository.open();
    final word = await repo.getRandomWord(
      language ?? settings.learningLanguage,
    );
    _currentWord = word;
    AppLogger.debug('WordProvider loaded random word: ${word.originalWord}');
    notifyListeners();
  }
}
