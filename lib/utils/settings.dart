// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart' as yaml;

// Project imports:
import 'package:lexigo/datas/word.dart';

class Settings {
  // Learning Settings
  LanguageCode learningLanguage;

  // FSRS Scheduler Settings
  double fsrsDesiredRetention;
  List<Duration> fsrsLearningSteps = [Duration(minutes: 1), Duration(minutes: 10)];
  List<Duration> fsrsRelearningSteps = [Duration(minutes: 10)];
  int fsrsMaximumInterval;
  bool fsrsEnableFuzzing;

  // General Settings
  Locale? locale;

  // Display Settings
  ThemeMode themeMode = ThemeMode.system;
  Color? colorSeed;

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

class SettingsStore extends ChangeNotifier {
  Settings _settings;

  SettingsStore(this._settings);

  Settings get settings => _settings;

  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final Directory appDir = await getApplicationSupportDirectory();
    final File settingsFile = File('${appDir.path}/settings.yaml');

    await settingsFile.writeAsString(_settings.toYamlString());
  }

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

  static double? _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

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
