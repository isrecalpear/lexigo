/// Main entry point for LexiGo flashcard learning application.
///
/// Sets up error handling, logging, and the root Material application with
/// support for dynamic colors, localization, and theme customization.

// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:navigation_rail_m3e/navigation_rail_m3e.dart';

// Project imports:
import 'datas/orm/word_repository.dart';
import 'datas/word.dart';
import 'l10n/app_localizations.dart';
import 'pages/my_page.dart';
import 'pages/records_page.dart';
import 'pages/start_page.dart';
import 'utils/app_logger.dart';
import 'utils/settings.dart';

/// Observes navigation events and logs route changes for debugging.
class AppRouteObserver extends NavigatorObserver {
  /// Logs when a route is pushed onto the navigation stack.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info(
      'Entering page: ${route.settings.name ?? route.runtimeType}',
    );
    super.didPush(route, previousRoute);
  }

  /// Logs when a route is popped from the navigation stack.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Exiting page: ${route.settings.name ?? route.runtimeType}');
    super.didPop(route, previousRoute);
  }

  /// Logs when a route is replaced with another route.
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.info(
      'Replacing page: ${oldRoute?.settings.name ?? oldRoute?.runtimeType} -> ${newRoute?.settings.name ?? newRoute?.runtimeType}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

/// Application entry point.
///
/// Initializes the logging system and sets up error handling for both
/// framework errors and uncaught asynchronous exceptions.
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

/// Builds a theme based on the provided colorScheme and brightness.
///
/// Uses Material 3 design. If [seedColor] is provided, generates a color scheme
/// from that seed. Otherwise, uses [dynamicScheme] or falls back to system defaults.
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

/// Root stateful widget that manages global app state and settings.
///
/// Manages learning language selection, UI locale, theme mode, and color seed.
/// Persists settings and provides them to the home page.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State for MyApp that handles settings loading and persistence.
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

  /// Updates the theme mode and persists it.
  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    final Settings updated = _settingsStore.settings.copyWith(themeMode: mode);
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }

  /// Updates the color seed and persists it.
  void _setColorSeed(Color? seed) {
    setState(() {
      _colorSeed = seed;
    });
    final Settings updated = _settingsStore.settings.copyWith(colorSeed: seed);
    _settingsStore.updateSettings(updated);
    unawaited(_settingsStore.saveSettings());
  }
}

/// Main home page widget with navigation tabs.
///
/// Contains three sections: Study (learning), Records (statistics), and Settings.
/// Manages the search functionality with debouncing and language-specific search.
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

  /// Currently selected learning language.
  final Locale? locale;

  /// Callback when learning language is changed.
  final ValueChanged<LanguageCode> onLearningLanguageChanged;

  /// Currently selected learning language code.
  final LanguageCode learningLanguage;

  /// Callback when UI locale is changed.
  final ValueChanged<Locale?> onLocaleChanged;

  /// Current theme mode setting.
  final ThemeMode themeMode;

  /// Callback when theme mode is changed.
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Current color seed (null = use dynamic/default colors).
  final Color? colorSeed;

  /// Callback when color seed is changed.
  final ValueChanged<Color?> onColorSeedChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for MyHomePage that manages page navigation and search.
class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  static const double _landscapeAspectRatioThreshold = 1.2;

  /// Debounce timer for search queries.
  Timer? _searchDebounceTimer;

  /// Outstanding search result completer.
  Completer<List<Word>>? _searchCompleter;

  /// Request ID to track outdated search requests.
  int _searchRequestId = 0;

  /// Debounce duration for search (300ms).
  static const Duration _searchDebounceDuration = Duration(milliseconds: 300);

  /// Cached last search results.
  Iterable<Widget> _lastOptions = <Widget>[];

  @override
  void initState() {
    super.initState();
    AppLogger.info('Main page initialized');
  }

  /// Cleans up search debounce timer on widget disposal.
  @override
  void dispose() {
    AppLogger.info('Main page disposed');
    _searchDebounceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool useRail =
        size.width / size.height >= _landscapeAspectRatioThreshold;
    final List<Widget> pages = [
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
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          if (useRail)
            SafeArea(
              child: NavigationRailM3E(
                type: NavigationRailM3EType.expanded,
                modality: NavigationRailM3EModality.standard,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                onTypeChanged: (_) {},
                sections: [
                  NavigationRailM3ESection(
                    destinations: [
                      NavigationRailM3EDestination(
                        icon: const Icon(Icons.abc_outlined),
                        selectedIcon: const Icon(Icons.abc),
                        label: context.l10n.tabStudy,
                      ),
                      NavigationRailM3EDestination(
                        icon: const Icon(Icons.calendar_month_outlined),
                        selectedIcon: const Icon(Icons.calendar_month),
                        label: context.l10n.tabRecords,
                      ),
                      NavigationRailM3EDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: const Icon(Icons.person),
                        label: context.l10n.tabMe,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    bottom: false,
                    minimum: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!useRail)
                          Text(
                            context.l10n.appTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        const Spacer(),
                        IconButton(
                          onPressed: _openLearningLanguagePicker,
                          icon: const Icon(Icons.language_outlined),
                        ),
                        SearchAnchor(
                          builder:
                              (
                                BuildContext context,
                                SearchController controller,
                              ) {
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
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : BottomNavigationBar(
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
    _pageController.jumpToPage(index);
  }

  /// Opens the learning language selection dialog.
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

  /// Handles search suggestions with debouncing.
  ///
  /// Debounces user input and returns word matches from the current language table.
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

  /// Performs debounced search with request cancellation.
  ///
  /// Cancels previous requests if a new search is triggered before completion.
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

  /// Executes the actual database search query.
  ///
  /// Searches words by originalWord, translation, example, and example translation.
  Future<List<Word>> _performSearch(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return <Word>[];
    }

    try {
      final repo = await WordRepository.open();
      return await repo.searchWords(
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
