// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'datas/orm/words.dart';
import 'datas/word.dart';
import 'l10n/app_localizations.dart';
import 'pages/my_page.dart';
import 'pages/records_page.dart';
import 'pages/start_page.dart';
import 'utils/app_logger.dart';
import 'utils/settings.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info(
      'Entering page: ${route.settings.name ?? route.runtimeType}',
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Exiting page: ${route.settings.name ?? route.runtimeType}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.info(
      'Replacing page: ${oldRoute?.settings.name ?? oldRoute?.runtimeType} -> ${newRoute?.settings.name ?? newRoute?.runtimeType}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the logging system
  await AppLogger.initialize();
  AppLogger.info('Application started');

  // Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Capture asynchronous errors
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stackTrace) {
      AppLogger.error(
        'Uncaught exception',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

ThemeData buildTheme(
  ColorScheme? dynamicScheme,
  bool isDarkMode, {
  Color? seedColor,
}) {
  final Brightness brightness = isDarkMode ? Brightness.dark : Brightness.light;
  final ColorScheme colorScheme = seedColor != null
      ? ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness)
      : (dynamicScheme ??
            (isDarkMode ? ColorScheme.dark() : ColorScheme.light()));
  return ThemeData(colorScheme: colorScheme, useMaterial3: true);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SettingsStore _settingsStore;
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  Color? _colorSeed;
  LanguageCode? _language;

  @override
  void initState() {
    super.initState();
    _settingsStore = SettingsStore(Settings.defaults());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsStore.loadSettings();
    final Settings settings = _settingsStore.settings;
    if (!mounted) {
      return;
    }
    setState(() {
      _language = settings.learningLanguage;
      _locale = settings.locale;
      _themeMode = settings.themeMode;
      _colorSeed = settings.colorSeed;
    });
  }

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    final Settings updated = _settingsStore.settings.copyWith(
      locale: locale,
      localeSet: true,
    );
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }

  void _setLearningLanguage(LanguageCode language) {
    setState(() {
      _language = language;
    });
    final Settings updated = _settingsStore.settings.copyWith(
      learningLanguage: language,
    );
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      AppLogger.warning(
        'iOS don\'t support dynamic color, using fallback color scheme',
      );
      ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: _colorSeed ?? Colors.pink.shade200,
      );
      return MaterialApp(
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildTheme(colorScheme, false, seedColor: _colorSeed),
        darkTheme: buildTheme(colorScheme, true, seedColor: _colorSeed),
        themeMode: _themeMode,
        navigatorObservers: [AppRouteObserver()],
        home: MyHomePage(
          locale: _locale,
          onLearningLanguageChanged: _setLearningLanguage,
          learningLanguage: _language ?? LanguageCode.en,
          onLocaleChanged: _setLocale,
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
          colorSeed: _colorSeed,
          onColorSeedChanged: _setColorSeed,
        ),
      );
    } else {
      return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            locale: _locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: buildTheme(lightDynamic, false, seedColor: _colorSeed),
            darkTheme: buildTheme(darkDynamic, true, seedColor: _colorSeed),
            themeMode: _themeMode,
            navigatorObservers: [AppRouteObserver()],
            home: MyHomePage(
              locale: _locale,
              onLearningLanguageChanged: _setLearningLanguage,
              learningLanguage: _language ?? LanguageCode.en,
              onLocaleChanged: _setLocale,
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
              colorSeed: _colorSeed,
              onColorSeedChanged: _setColorSeed,
            ),
          );
        },
      );
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    final Settings updated = _settingsStore.settings.copyWith(themeMode: mode);
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }

  void _setColorSeed(Color? seed) {
    setState(() {
      _colorSeed = seed;
    });
    final Settings updated = _settingsStore.settings.copyWith(colorSeed: seed);
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.learningLanguage,
    required this.onLearningLanguageChanged,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorSeed,
    required this.onColorSeedChanged,
  });


  final Locale? locale;
  final ValueChanged<LanguageCode> onLearningLanguageChanged;
  final LanguageCode learningLanguage;
  final ValueChanged<Locale?> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color? colorSeed;
  final ValueChanged<Color?> onColorSeedChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  Timer? _searchDebounceTimer;
  Completer<List<Word>>? _searchCompleter;
  int _searchRequestId = 0;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 300);
  Iterable<Widget> _lastOptions = <Widget>[];

  @override
  void initState() {
    super.initState();
    AppLogger.info('Main page initialized');
  }

  @override
  void dispose() {
    AppLogger.info('Main page disposed');
    _searchDebounceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            onPressed: _openLearningLanguagePicker,
            icon: const Icon(Icons.language_outlined),
          ),
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.openView();
                },
              );
            },
            suggestionsBuilder: _suggestionsBuilder,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          StartPage(learningLanguage: widget.learningLanguage),
          const RecordsPicker(),
          SettingsPage(
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            colorSeed: widget.colorSeed,
            onColorSeedChanged: widget.onColorSeedChanged,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.abc_outlined),
            label: context.l10n.tabStudy,
            activeIcon: const Icon(Icons.abc),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            label: context.l10n.tabRecords,
            activeIcon: const Icon(Icons.calendar_month),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: context.l10n.tabMe,
            activeIcon: const Icon(Icons.person),
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    AppLogger.debug('Switching to tab: $index');
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openLearningLanguagePicker() async {
    final LanguageCode? selected = await showDialog<LanguageCode>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.selectLanguageTitle),
          children: LanguageCode.values
              .map(
                (item) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, item),
                  child: Text(item.name),
                ),
              )
              .toList(),
        );
      },
    );

    if (selected == null || selected == widget.learningLanguage) {
      return;
    }

    widget.onLearningLanguageChanged(selected);
  }

  Future<Iterable<Widget>> _suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    final String query = controller.text.trim();
    if (query.isEmpty) {
      _lastOptions = <Widget>[];
      return _lastOptions;
    }

    final List<Word> results = await _debouncedSearch(query);

    if (query != controller.text.trim()) {
      return _lastOptions;
    }

    _lastOptions = results
        .map(
          (word) => ListTile(
            title: Text(word.originalWord),
            subtitle: Text(word.translation),
            onTap: () {
              controller.closeView(word.originalWord);
            },
          ),
        )
        .toList();

    return _lastOptions;
  }

  Future<List<Word>> _debouncedSearch(String query) async {
    _searchDebounceTimer?.cancel();
    if (_searchCompleter != null && !_searchCompleter!.isCompleted) {
      _searchCompleter!.complete(<Word>[]);
    }
    final completer = Completer<List<Word>>();
    _searchCompleter = completer;
    final int requestId = ++_searchRequestId;

    _searchDebounceTimer = Timer(_searchDebounceDuration, () async {
      final List<Word> results = await _performSearch(query);
      if (requestId != _searchRequestId) {
        return;
      }
      if (!completer.isCompleted) {
        completer.complete(results);
      }
    });

    return completer.future;
  }

  Future<List<Word>> _performSearch(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return <Word>[];
    }

    try {
      final dao = await WordDao.open();
      return await dao.searchWords(
        widget.learningLanguage,
        trimmed,
        limit: 20,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to search words',
        error: e,
        stackTrace: stackTrace,
      );
      return <Word>[];
    }
  }
}
