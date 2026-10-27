/// Central route table for LexiGo.
///
/// Every page transition is declared here instead of being scattered across the
/// UI as ad-hoc `MaterialPageRoute` literals. This keeps navigation consistent,
/// gives each route a stable name for logging and analytics, and leaves a single
/// place to migrate to a declarative router later.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'package:lexigo/pages/learning/learn.dart';
import 'package:lexigo/pages/learning/learning_summarize.dart';
import 'package:lexigo/pages/my_page/log_management/log_management.dart';
import 'package:lexigo/pages/my_page/log_management/log_view.dart';
import 'package:lexigo/pages/my_page/settings_editing.dart';
import 'package:lexigo/pages/my_page/word_management/word_add.dart';
import 'package:lexigo/pages/my_page/word_management/word_edit.dart';
import 'package:lexigo/pages/my_page/word_management/word_management.dart';
import 'package:lexigo/pages/my_page/word_management/word_view.dart';

/// Stable route names, also surfaced by the route observer in app logs.
abstract final class AppRoute {
  static const String wordManagement = '/me/words';
  static const String wordList = '/me/words/list';
  static const String wordAdd = '/me/words/add';
  static const String wordEdit = '/me/words/edit';
  static const String logManagement = '/me/logs';
  static const String logView = '/me/logs/view';
  static const String settingsEditing = '/me/settings';
  static const String learning = '/study/learning';
  static const String learningSummary = '/study/summary';
}

/// Builders for every page transition in the app.
///
/// Argument types stay explicit (no `Object? arguments`), so a route can only be
/// pushed with the data its page actually needs.
abstract final class AppRoutes {
  static Route<T> _page<T>(String name, WidgetBuilder builder) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: name),
      builder: builder,
    );
  }

  static Route<void> wordManagement() {
    return _page(AppRoute.wordManagement, (_) => WordManagement());
  }

  static Route<void> wordList() {
    return _page(AppRoute.wordList, (_) => const WordViewPage());
  }

  static Route<void> wordAdd({LanguageCode? languageCode}) {
    return _page(
      AppRoute.wordAdd,
      (_) => WordAddPage(languageCode: languageCode),
    );
  }

  /// Returns the updated word when the editor saved, `null` when it was
  /// dismissed.
  static Route<Word> wordEdit({required Word word, required fsrs.Card card}) {
    return _page(
      AppRoute.wordEdit,
      (_) => WordEditPage(word: word, card: card),
    );
  }

  static Route<void> logManagement() {
    return _page(AppRoute.logManagement, (_) => const LogManagementPage());
  }

  static Route<void> logView() {
    return _page(AppRoute.logView, (_) => const LogViewPage());
  }

  static Route<void> settingsEditing({
    required Locale? locale,
    required ValueChanged<Locale?> onLocaleChanged,
    required ThemeMode themeMode,
    required ValueChanged<ThemeMode> onThemeModeChanged,
    required Color? colorSeed,
    required ValueChanged<Color?> onColorSeedChanged,
  }) {
    return _page(
      AppRoute.settingsEditing,
      (_) => SettingsEditingPage(
        locale: locale,
        onLocaleChanged: onLocaleChanged,
        themeMode: themeMode,
        onThemeModeChanged: onThemeModeChanged,
        colorSeed: colorSeed,
        onColorSeedChanged: onColorSeedChanged,
      ),
    );
  }

  /// Returns the word that was on screen when the session ended.
  static Route<Word?> learning({
    required Word word,
    required LanguageCode languageCode,
    required WordProvider wordProvider,
  }) {
    return _page(
      AppRoute.learning,
      (_) => LearningPage(
        word: word,
        learningLanguage: languageCode,
        wordProvider: wordProvider,
      ),
    );
  }

  static Route<void> learningSummary({
    required Word wordsUnknown,
    required int wordsLearned,
    required int wordsReviewed,
    required int wordsToReview,
    required WordProvider wordProvider,
  }) {
    return _page(
      AppRoute.learningSummary,
      (_) => LearningSummarizePage(
        wordsUnknown: wordsUnknown,
        wordsLearned: wordsLearned,
        wordsReviewed: wordsReviewed,
        wordsToReview: wordsToReview,
        wordProvider: wordProvider,
      ),
    );
  }
}
