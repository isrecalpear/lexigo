// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'l10n/app_localizations.dart';
import 'pages/records.dart';
import 'pages/settings_page.dart';
import 'pages/start_page.dart';
import 'utils/app_logger.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Entering page: ${route.settings.name ?? route.runtimeType}');
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
      AppLogger.error('Uncaught exception', error: error, stackTrace: stackTrace);
    },
  );
}

ThemeData buildTheme(ColorScheme? dynamicScheme, bool isDarkMode) {
  ColorScheme colorScheme =
      dynamicScheme ?? (isDarkMode ? ColorScheme.dark() : ColorScheme.light());
  return ThemeData(colorScheme: colorScheme, useMaterial3: true);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      AppLogger.warning('iOS don\'t support dynamic color, using fallback color scheme');
      ColorScheme colorScheme =
          ColorScheme.fromSeed(seedColor: Colors.pink.shade200);
      return MaterialApp(
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildTheme(colorScheme, false),
        darkTheme: buildTheme(colorScheme, true),
        themeMode: ThemeMode.system,
        navigatorObservers: [AppRouteObserver()],
        home: MyHomePage(
          locale: _locale,
          onLocaleChanged: _setLocale,
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
            theme: buildTheme(lightDynamic, false),
            darkTheme: buildTheme(darkDynamic, true),
            themeMode: ThemeMode.system,
            navigatorObservers: [AppRouteObserver()],
            home: MyHomePage(
              locale: _locale,
              onLocaleChanged: _setLocale,
            ),
          );
        },
      );
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.info('Main page initialized');
  }

  @override
  void dispose() {
    AppLogger.info('Main page disposed');
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () => _showLanguagePicker(context),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: const [StartPage(), RecordsPicker(), SettingsPage()],
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

  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<Locale?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.languageSystem),
                trailing: widget.locale == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, null),
              ),
              ListTile(
                title: Text(l10n.languageChinese),
                trailing: widget.locale?.languageCode == 'zh'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, const Locale('zh')),
              ),
              ListTile(
                title: Text(l10n.languageEnglish),
                trailing: widget.locale?.languageCode == 'en'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, const Locale('en')),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected != widget.locale) {
      widget.onLocaleChanged(selected);
    }
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

  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];

  Future<Iterable<Widget>> _suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) async {
    _searchingWithQuery = controller.text;
    final List<String> options = (await _performSearch(
      _searchingWithQuery!,
    )).toList();

    // If another search happened after this one, throw away these options.
    // Use the previous options instead and wait for the newer request to
    // finish.
    if (_searchingWithQuery != controller.text) {
      return _lastOptions;
    }

    _lastOptions = List<ListTile>.generate(options.length, (int index) {
      final String item = options[index];
      return ListTile(title: Text(item));
    });

    return _lastOptions;
  }

  // Searches the options, but injects a fake "network" delay.
  static Future<Iterable<String>> _performSearch(String query) async {
    await Future<void>.delayed(Duration(seconds: 1)); // Fake 1 second delay.
    if (query == '') {
      return const Iterable<String>.empty();
    }
    return _kOptions.where((String option) {
      return option.contains(query.toLowerCase());
    });
  }
}
