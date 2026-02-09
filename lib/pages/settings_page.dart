// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/log_management/log_management_page.dart';
import 'package:lexigo/pages/settings_editing_page.dart';
import 'package:lexigo/pages/word_management/word_management.dart';
import 'package:lexigo/utils/app_logger.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorSeed,
    required this.onColorSeedChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color? colorSeed;
  final ValueChanged<Color?> onColorSeedChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(context.l10n.settingsWordManagement),
            subtitle: Text(context.l10n.settingsWordManagementSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening word management page');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordManagement()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(context.l10n.settingsEditSettings),
            subtitle: Text(context.l10n.settingsEditSettingsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening settings editing page');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsEditingPage(
                    locale: locale,
                    onLocaleChanged: onLocaleChanged,
                    themeMode: themeMode,
                    onThemeModeChanged: onThemeModeChanged,
                    colorSeed: colorSeed,
                    onColorSeedChanged: onColorSeedChanged,
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(context.l10n.settingsLogManagement),
            subtitle: Text(context.l10n.settingsLogManagementSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening log management page');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogManagementPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.l10n.settingsAbout),
            subtitle: Text(context.l10n.settingsAboutSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('Opening about page');
              showAboutDialog(
                context: context,
                applicationName: context.l10n.appTitle,
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
