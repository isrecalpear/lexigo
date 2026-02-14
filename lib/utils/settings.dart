/// Application settings and configuration management.
///
/// This file manages all user preferences including learning language,
/// FSRS scheduler settings, UI locale, theme, and color scheme.
/// Settings are persisted to disk in YAML format.

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart' as yaml;

// Project imports:
import 'package:lexigo/datas/word.dart';

/// Immutable settings configuration.
///
/// Contains all user preferences for learning (language selection),
/// FSRS scheduling parameters, UI localization, theme, and color customization.
/// Use [copyWith] to create modified copies for state management.
class Settings {
  /// The language currently selected for learning.
  LanguageCode learningLanguage;

  /// FSRS target retention rate (0.0-1.0). Higher values mean more frequent reviews.
  double fsrsDesiredRetention;

  /// Learning steps for new cards (in minutes between reviews).
  List<Duration> fsrsLearningSteps = [
    Duration(minutes: 1),
    Duration(minutes: 10),
  ];

  /// Relearning steps for cards that were failed (in minutes between reviews).
  List<Duration> fsrsRelearningSteps = [Duration(minutes: 10)];

  /// Maximum interval (in days) between reviews.
  int fsrsMaximumInterval;

  /// Whether to enable fuzzing (randomization) in scheduling.
  bool fsrsEnableFuzzing;

  /// UI language locale (null means system default).
  Locale? locale;

  /// Theme mode (system, light, or dark).
  ThemeMode themeMode = ThemeMode.system;

  /// Custom theme color seed (null means use dynamic/default colors).
  Color? colorSeed;

  /// Creates a Settings instance with all required parameters.
  Settings({
    required this.learningLanguage,
    required this.fsrsDesiredRetention,
    required this.fsrsLearningSteps,
    required this.fsrsRelearningSteps,
    required this.fsrsMaximumInterval,
    required this.fsrsEnableFuzzing,
    required this.locale,
    required this.themeMode,
    required this.colorSeed,
  });

  /// Creates default Settings with recommended values.
  ///
  /// Default learning language is English.
  /// FSRS parameters follow standard spaced repetition best practices.
  factory Settings.defaults() {
    return Settings(
      learningLanguage: LanguageCode.en,
      fsrsDesiredRetention: 0.9,
      fsrsLearningSteps: [Duration(minutes: 1), Duration(minutes: 10)],
      fsrsRelearningSteps: [Duration(minutes: 10)],
      fsrsMaximumInterval: 365,
      fsrsEnableFuzzing: true,
      locale: null,
      themeMode: ThemeMode.system,
      colorSeed: null,
    );
  }

  /// Creates a copy of this Settings with specified fields replaced.
  ///
  /// If [localeSet] is false, the locale field is unchanged (used for system locale).
  Settings copyWith({
    LanguageCode? learningLanguage,
    double? fsrsDesiredRetention,
    List<Duration>? fsrsLearningSteps,
    List<Duration>? fsrsRelearningSteps,
    int? fsrsMaximumInterval,
    bool? fsrsEnableFuzzing,
    Locale? locale,
    bool localeSet = false,
    ThemeMode? themeMode,
    Color? colorSeed,
  }) {
    return Settings(
      learningLanguage: learningLanguage ?? this.learningLanguage,
      fsrsDesiredRetention: fsrsDesiredRetention ?? this.fsrsDesiredRetention,
      fsrsLearningSteps: fsrsLearningSteps ?? this.fsrsLearningSteps,
      fsrsRelearningSteps: fsrsRelearningSteps ?? this.fsrsRelearningSteps,
      fsrsMaximumInterval: fsrsMaximumInterval ?? this.fsrsMaximumInterval,
      fsrsEnableFuzzing: fsrsEnableFuzzing ?? this.fsrsEnableFuzzing,
      locale: localeSet ? locale : this.locale,
      themeMode: themeMode ?? this.themeMode,
      colorSeed: colorSeed ?? this.colorSeed,
    );
  }

  /// Serializes all settings to a Map for storage.
  Map<String, dynamic> serializedSettings() {
    return {
      'learningLanguage': learningLanguage.toString(),
      'fsrsDesiredRetention': fsrsDesiredRetention,
      'fsrsLearningSteps': fsrsLearningSteps.map((e) => e.inSeconds).toList(),
      'fsrsRelearningSteps': fsrsRelearningSteps
          .map((e) => e.inSeconds)
          .toList(),
      'fsrsMaximumInterval': fsrsMaximumInterval,
      'fsrsEnableFuzzing': fsrsEnableFuzzing,
      'locale': locale?.toString(),
      'themeMode': themeMode.toString(),
      'colorSeed': colorSeed?.toARGB32(),
    };
  }

  /// Converts settings to YAML format for persistent storage.
  String toYamlString() {
    final Map<String, dynamic> data = serializedSettings();
    final StringBuffer buffer = StringBuffer();

    for (final MapEntry<String, dynamic> entry in data.entries) {
      buffer
        ..write(entry.key)
        ..write(': ')
        ..writeln(_yamlValue(entry.value));
    }

    return buffer.toString();
  }

  /// Formats a value for YAML serialization.
  static String _yamlValue(dynamic value) {
    if (value == null) {
      return 'null';
    }

    if (value is String) {
      final String escaped = value.replaceAll('"', '\\"');
      return '"$escaped"';
    }

    if (value is bool || value is num) {
      return value.toString();
    }

    if (value is List) {
      final String items = value.map(_yamlValue).join(', ');
      return '[$items]';
    }

    return '"${value.toString()}"';
  }
}

/// State management for Settings with persistence.
///
/// Extends [ChangeNotifier] to work with Provider pattern.
/// Handles loading/saving settings from disk in YAML format.
class SettingsStore extends ChangeNotifier {
  Settings _settings;

  /// Initialize with initial settings.
  SettingsStore(this._settings);

  /// Get the current settings.
  Settings get settings => _settings;

  /// Update settings and notify listeners.
  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Saves current settings to disk in YAML format.
  Future<void> saveSettings() async {
    final Directory appDir = await getApplicationSupportDirectory();
    final File settingsFile = File('${appDir.path}/settings.yaml');

    await settingsFile.writeAsString(_settings.toYamlString());
  }

  /// Loads settings from disk and updates the store.
  /// Creates default settings if file doesn't exist.
  Future<void> loadSettings() async {
    final Directory appDir = await getApplicationSupportDirectory();
    final File settingsFile = File('${appDir.path}/settings.yaml');

    if (await settingsFile.exists()) {
      final String content = await settingsFile.readAsString();
      final yaml.YamlNode? root = yaml.loadYaml(content);
      if (root is! yaml.YamlMap) {
        return;
      }
      final yaml.YamlMap yamlMap = root;

      Locale? locale = _parseLocale(yamlMap['locale']?.toString());

      ThemeMode? themeMode;
      if (yamlMap['themeMode'] == 'ThemeMode.light') {
        themeMode = ThemeMode.light;
      } else if (yamlMap['themeMode'] == 'ThemeMode.dark') {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.system;
      }

      Color? colorSeed;
      final dynamic colorSeedValue = yamlMap['colorSeed'];
      if (colorSeedValue is int) {
        colorSeed = Color(colorSeedValue);
      }

      _settings = Settings(
        learningLanguage: LanguageCode.values.firstWhere(
          (e) => e.toString() == yamlMap['learningLanguage'],
          orElse: () => LanguageCode.en,
        ),
        fsrsDesiredRetention:
            _parseDouble(yamlMap['fsrsDesiredRetention']) ?? 0.9,
        fsrsLearningSteps:
            _parseDurationList(
              yamlMap['fsrsLearningSteps'],
              fallback: [Duration(minutes: 1), Duration(minutes: 10)],
            ) ??
            [Duration(minutes: 1), Duration(minutes: 10)],
        fsrsRelearningSteps:
            _parseDurationList(
              yamlMap['fsrsRelearningSteps'],
              fallback: [Duration(minutes: 10)],
            ) ??
            [Duration(minutes: 10)],
        fsrsMaximumInterval: yamlMap['fsrsMaximumInterval'] ?? 365,
        fsrsEnableFuzzing: yamlMap['fsrsEnableFuzzing'] ?? true,
        locale: locale,
        themeMode: themeMode,
        colorSeed: colorSeed,
      );

      notifyListeners();
    }
  }

  /// Parses a locale string (e.g., 'en_US') to a Locale object.
  static Locale? _parseLocale(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null' || raw == 'system') {
      return null;
    }

    final List<String> parts = raw.split('_');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }

    return Locale(parts[0]);
  }

  /// Safely parses a value to double.
  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  /// Safely parses a list of durations from various formats.
  static List<Duration>? _parseDurationList(
    dynamic value, {
    required List<Duration> fallback,
  }) {
    if (value is! List) {
      return fallback;
    }

    return value
        .map((dynamic item) {
          if (item is num) {
            return Duration(seconds: item.toInt());
          }
          if (item is String) {
            final int? seconds = int.tryParse(item);
            if (seconds != null) {
              return Duration(seconds: seconds);
            }
          }
          return null;
        })
        .whereType<Duration>()
        .toList();
  }
}
