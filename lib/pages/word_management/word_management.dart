import 'package:flutter/material.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/pages/word_management/word_view_page.dart';
import 'package:lexigo/pages/word_management/word_add_page.dart';
import 'package:file_selector/file_selector.dart';

class WordManagement extends StatelessWidget {
  const WordManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('单词管理')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('查看单词'),
            subtitle: const Text('查看单词清单'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('打开查看单词页面');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordViewPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.import_export_outlined),
            title: const Text('导入单词清单'),
            subtitle: const Text('从外部文件导入单词清单'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('选择文件导入单词清单');
              _importWords();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('添加单词'),
            subtitle: const Text('手动添加单词到数据库'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppLogger.info('打开添加单词页面');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WordAddPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _importWords() async {
    // TODO 
  }
}
