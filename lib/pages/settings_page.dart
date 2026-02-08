// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/log_management/log_management_page.dart';
import 'package:lexigo/pages/word_management/word_management.dart';
import 'package:lexigo/utils/app_logger.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              AppLogger.info('打开单词管理页面');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordManagement()),
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
              AppLogger.info('打开日志管理页面');
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
              AppLogger.info('打开关于页面');
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
