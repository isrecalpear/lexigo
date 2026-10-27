/// Main entry point for LexiGo flashcard learning application.
///
/// Sets up error handling, logging, and the root Material application with
/// support for dynamic colors, localization, and theme customization.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:lexigo/backend/word/manager.dart';
import 'backend/word.dart';
import 'l10n/l10n.dart';
import 'pages/my_page.dart';
import 'package:lexigo/pages/records/records_page.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'pages/start_page.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'utils/app_font.dart';
import 'utils/app_logger.dart';
import 'utils/device_info.dart';
import 'utils/font_manager.dart';
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
  late final WordProvider _wordProvider;
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;
  Color? _colorSeed;
  LanguageCode? _language;
  AppFont _font = AppFont.system;

  @override
  void initState() {
    super.initState();
    _wordProvider = WordProvider();
    if (!DeviceInfoManager().supportsDynamicColor) {
      AppLogger.warning(
        'Current platform don\'t support dynamic color, using fallback color scheme',
      );
    }
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await SettingsStore.instance.loadSettings();
    final Settings settings = SettingsStore.instance.settings;

    // Optional fonts are downloaded on demand, so the user may have selected a
    // font whose cache was later removed. Fall back to the system font instead
    // of showing broken text.
    AppFont font = settings.font;
    if (!font.isSystem) {
      final bool loaded = await FontManager.instance.loadFont(font);
      if (!loaded) {
        AppLogger.warning(
          'Selected font ${font.storageId} is not installed, using system font',
        );
        font = AppFont.system;
        SettingsStore.instance.updateSettings(
          settings.copyWith(font: AppFont.system),
        );
        unawaited(SettingsStore.instance.saveSettings());
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _language = settings.learningLanguage;
      _locale = settings.locale;
      _themeMode = settings.themeMode;
      _colorSeed = settings.colorSeed;
      _font = font;
    });
    unawaited(_wordProvider.loadRandomWord());
  }

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    final Settings updated = SettingsStore.instance.settings.copyWith(
      locale: locale,
      localeSet: true,
    );
    SettingsStore.instance.updateSettings(updated);
    unawaited(SettingsStore.instance.saveSettings());
  }

  void _setLearningLanguage(LanguageCode language) {
    setState(() {
      _language = language;
    });
    final Settings updated = SettingsStore.instance.settings.copyWith(
      learningLanguage: language,
    );
    SettingsStore.instance.updateSettings(updated);
    unawaited(SettingsStore.instance.saveSettings());
    unawaited(_wordProvider.loadRandomWord());
  }

  @override
  Widget build(BuildContext context) {
    final LanguageCode learningLanguage = _language ?? LanguageCode.en;

    if (!DeviceInfoManager().supportsDynamicColor) {
      return _buildMaterialApp(
        lightColorScheme: null,
        darkColorScheme: null,
        learningLanguage: learningLanguage,
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return _buildMaterialApp(
          lightColorScheme: lightDynamic,
          darkColorScheme: darkDynamic,
          learningLanguage: learningLanguage,
        );
      },
    );
  }

  /// Builds the root [MaterialApp].
  ///
  /// The two call sites (dynamic color supported or not) only differ in the
  /// color schemes they provide, so the shared configuration lives here.
  Widget _buildMaterialApp({
    required ColorScheme? lightColorScheme,
    required ColorScheme? darkColorScheme,
    required LanguageCode learningLanguage,
  }) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.build(
        brightness: Brightness.light,
        dynamicScheme: lightColorScheme,
        seedColor: _colorSeed,
        fontFamily: _font.familyName,
      ),
      darkTheme: AppTheme.build(
        brightness: Brightness.dark,
        dynamicScheme: darkColorScheme,
        seedColor: _colorSeed,
        fontFamily: _font.familyName,
      ),
      themeMode: _themeMode,
      navigatorObservers: [AppRouteObserver()],
      home: MyHomePage(
        locale: _locale,
        onLearningLanguageChanged: _setLearningLanguage,
        learningLanguage: learningLanguage,
        onLocaleChanged: _setLocale,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        colorSeed: _colorSeed,
        onColorSeedChanged: _setColorSeed,
        font: _font,
        onFontChanged: _setFont,
        wordProvider: _wordProvider,
      ),
    );
  }

  /// Updates the theme mode and persists it.
  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    final Settings updated = SettingsStore.instance.settings.copyWith(
      themeMode: mode,
    );
    SettingsStore.instance.updateSettings(updated);
    unawaited(SettingsStore.instance.saveSettings());
  }

  /// Updates the color seed and persists it.
  ///
  /// `colorSeedSet: true` is required so that picking "Auto" (a null seed) is
  /// actually persisted instead of keeping the previous color.
  void _setColorSeed(Color? seed) {
    setState(() {
      _colorSeed = seed;
    });
    final Settings updated = SettingsStore.instance.settings.copyWith(
      colorSeed: seed,
      colorSeedSet: true,
    );
    SettingsStore.instance.updateSettings(updated);
    unawaited(SettingsStore.instance.saveSettings());
  }

  /// Updates the UI font and persists it.
  ///
  /// The font files are downloaded and registered by the settings page before
  /// this callback runs, so only the theme has to be rebuilt here.
  void _setFont(AppFont font) {
    setState(() {
      _font = font;
    });
    final Settings updated = SettingsStore.instance.settings.copyWith(
      font: font,
    );
    SettingsStore.instance.updateSettings(updated);
    unawaited(SettingsStore.instance.saveSettings());
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
    required this.font,
    required this.onFontChanged,
    required this.wordProvider,
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

  /// Currently applied UI font.
  final AppFont font;

  /// Callback when the UI font is changed.
  final ValueChanged<AppFont> onFontChanged;

  /// Centralized word state provider shared across learning-flow pages.
  final WordProvider wordProvider;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for MyHomePage that manages page navigation and search.
class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  final DeviceInfoManager _deviceInfoManager = DeviceInfoManager();
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

  final _wordManager = WordManager();

  @override
  void initState() {
    super.initState();
    AppLogger.info('Main page initialized');
    _initializeDeviceInfo();
  }

  /// Initializes device information.
  Future<void> _initializeDeviceInfo() async {
    await _deviceInfoManager.initialize();
    if (mounted) {
      setState(() {});
    }
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
      StartPage(
        learningLanguage: widget.learningLanguage,
        wordProvider: widget.wordProvider,
      ),
      RecordsPage(active: _selectedIndex == 1),
      SettingsPage(
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        colorSeed: widget.colorSeed,
        onColorSeedChanged: widget.onColorSeedChanged,
        font: widget.font,
        onFontChanged: widget.onFontChanged,
      ),
    ];

    return Scaffold(
      bottomNavigationBar: useRail ? null : _buildBottomNavigation(context),
      body: Row(
        children: [
          if (useRail)
            SafeArea(
              child: NavigationRail(
                groupAlignment: _deviceInfoManager.isPadDevice() ? -1.0 : 0.0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: _buildRailDestinations(context),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
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
    );
  }

  /// Top header used by every tab: brand lockup, current section, and the
  /// global actions (learning language + word search).
  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        child: Row(
          children: <Widget>[
            _buildBrandMark(context),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'LexiGo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
            ),
            AppPill(
              label: _languageLabel(context, widget.learningLanguage),
              icon: Icons.translate_rounded,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              onTap: _openLearningLanguagePicker,
            ),
            const SizedBox(width: AppSpacing.xs),
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return IconButton.filledTonal(
                  tooltip: l10n.searchHint,
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => controller.openView(),
                );
              },
              suggestionsBuilder: _suggestionsBuilder,
            ),
          ],
        ),
      ),
    );
  }

  /// Rounded brand mark shown in the header and the navigation rail.
  Widget _buildBrandMark(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        color: colors.onPrimaryContainer,
        size: 22,
      ),
    );
  }

  /// Bottom navigation bar used in portrait layouts.
  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      destinations: _buildDestinations(context),
      onDestinationSelected: _onItemTapped,
    );
  }

  /// Navigation rail destinations used on wide screens.
  List<NavigationRailDestination> _buildRailDestinations(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return <NavigationRailDestination>[
      NavigationRailDestination(
        icon: const Icon(Icons.style_outlined),
        selectedIcon: const Icon(Icons.style_rounded),
        label: Text(l10n.tabStudy),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights_rounded),
        label: Text(l10n.tabRecords),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.tabMe),
      ),
    ];
  }

  /// Bottom navigation destinations used in portrait layouts.
  List<NavigationDestination> _buildDestinations(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.style_outlined),
        selectedIcon: const Icon(Icons.style_rounded),
        label: l10n.tabStudy,
      ),
      NavigationDestination(
        icon: const Icon(Icons.insights_outlined),
        selectedIcon: const Icon(Icons.insights_rounded),
        label: l10n.tabRecords,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: l10n.tabMe,
      ),
    ];
  }

  /// Localized display name of a learning language.
  String _languageLabel(BuildContext context, LanguageCode language) {
    return switch (language) {
      LanguageCode.en => context.l10n.languageEnglishName,
      LanguageCode.ko => context.l10n.languageKoreanName,
      LanguageCode.ru => context.l10n.languageRussianName,
    };
  }

  void _onItemTapped(int index) {
    AppLogger.debug('Switching to tab: $index');
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  /// Opens the learning language picker as a modal bottom sheet.
  Future<void> _openLearningLanguagePicker() async {
    final LanguageCode currentLanguage = widget.learningLanguage;
    final List<LanguageCode> languageOptions = <LanguageCode>[
      currentLanguage,
      ...LanguageCode.values.where((item) => item != currentLanguage),
    ];

    final LanguageCode? selected = await showModalBottomSheet<LanguageCode>(
      context: context,
      builder: (BuildContext sheetContext) {
        final AppLocalizations l10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Text(
                    l10n.selectLanguageTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                for (final LanguageCode language in languageOptions)
                  AppChoiceTile<LanguageCode>(
                    value: language,
                    groupValue: currentLanguage,
                    title: _languageLabel(sheetContext, language),
                    icon: Icons.translate_rounded,
                    onSelected: (LanguageCode value) {
                      Navigator.pop(sheetContext, value);
                    },
                  ),
              ],
            ),
          ),
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
            leading: AppIconBadge(
              icon: Icons.translate_rounded,
              size: 36,
              iconSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(word.originalWord),
            subtitle: Text(
              word.originalTranslation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.north_east_rounded, size: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
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
      return await _wordManager.searchWords(widget.learningLanguage, trimmed);
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
