/// Settings page with menu for word and app configuration management.
///
/// Provides access to word management, settings editing, logs, and app info.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_font.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Application version shown in the brand header and the about dialog.
const String _appVersion = '1.0.0';

/// Settings menu page with navigation to sub-pages.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorSeed,
    required this.onColorSeedChanged,
    required this.font,
    required this.onFontChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color? colorSeed;
  final ValueChanged<Color?> onColorSeedChanged;
  final AppFont font;
  final ValueChanged<AppFont> onFontChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: AppContent(
          child: ListView(
            padding: AppInsets.page,
            children: <Widget>[
              AppSettingsGroup(
                title: l10n.sectionWords,
                children: <Widget>[
                  AppSettingsTile(
                    icon: Icons.menu_book_rounded,
                    iconColor: colors.tertiary,
                    title: l10n.settingsWordManagement,
                    subtitle: l10n.settingsWordManagementSubtitle,
                    onTap: () {
                      AppLogger.info('Opening word management page');
                      Navigator.push(context, AppRoutes.wordManagement());
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSettingsGroup(
                title: l10n.sectionSettings,
                children: <Widget>[
                  AppSettingsTile(
                    icon: Icons.tune_rounded,
                    iconColor: colors.primary,
                    title: l10n.settingsEditSettings,
                    subtitle: l10n.settingsEditSettingsSubtitle,
                    onTap: () {
                      AppLogger.info('Opening settings editing page');
                      Navigator.push(
                        context,
                        AppRoutes.settingsEditing(
                          locale: locale,
                          onLocaleChanged: onLocaleChanged,
                          themeMode: themeMode,
                          onThemeModeChanged: onThemeModeChanged,
                          colorSeed: colorSeed,
                          onColorSeedChanged: onColorSeedChanged,
                          font: font,
                          onFontChanged: onFontChanged,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSettingsGroup(
                title: l10n.sectionData,
                children: <Widget>[
                  AppSettingsTile(
                    icon: Icons.description_rounded,
                    iconColor: colors.secondary,
                    title: l10n.settingsLogManagement,
                    subtitle: l10n.settingsLogManagementSubtitle,
                    onTap: () {
                      AppLogger.info('Opening log management page');
                      Navigator.push(context, AppRoutes.logManagement());
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSettingsGroup(
                title: l10n.sectionAbout,
                children: <Widget>[
                  AppSettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: colors.onSurfaceVariant,
                    title: l10n.settingsAbout,
                    subtitle: l10n.settingsAboutSubtitle,
                    onTap: () {
                      AppLogger.info('Opening about page');
                      showAboutDialog(
                        context: context,
                        applicationName: l10n.appTitle,
                        applicationVersion: _appVersion,
                        applicationIcon: AppIconBadge(
                          icon: Icons.auto_stories_rounded,
                          color: colors.primary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  '${l10n.appTitle} · v$_appVersion',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
