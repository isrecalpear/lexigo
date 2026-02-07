import 'package:flutter/material.dart';
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
            title: const Text('单词管理'),
            subtitle: const Text('查看与维护单词数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('打开单词管理页面');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WordManagement(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('日志管理'),
            subtitle: const Text('查看和管理应用日志'),
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
            title: const Text('关于'),
            subtitle: const Text('LexiGo - 背了么'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('打开关于页面');
              showAboutDialog(
                context: context,
                applicationName: 'LexiGo',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}

