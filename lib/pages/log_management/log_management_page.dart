import 'package:flutter/material.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/pages/log_management/log_view_page.dart';

/// 日志管理页面
class LogManagementPage extends StatefulWidget {
  const LogManagementPage({super.key});

  @override
  State<LogManagementPage> createState() => _LogManagementPageState();
}

class _LogManagementPageState extends State<LogManagementPage> {
  double _logSize = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogInfo();
  }

  Future<void> _loadLogInfo() async {
    setState(() => _isLoading = true);
    try {
      final size = await AppLogger.getLogSize();
      setState(() {
        _logSize = size;
        _isLoading = false;
      });
      AppLogger.debug('加载日志信息: 大小=${size.toStringAsFixed(2)}MB');
    } catch (e) {
      AppLogger.error('加载日志信息失败', error: e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AppLogger.clearAllLogs();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('日志已清除')));
          await _loadLogInfo();
        }
      } catch (e) {
        AppLogger.error('清除日志失败', error: e);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清除失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日志管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('日志大小'),
                  subtitle: Text('${_logSize.toStringAsFixed(2)} MB'),
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('日志查看'),
                  subtitle: const Text('查看最新日志'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    AppLogger.info('打开日志查看页面');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogViewPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于日志'),
                  subtitle: const Text('日志文件保存在应用数据目录，最多保留7天，超过后自动删除旧日志。'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _loadLogInfo,
                        icon: const Icon(Icons.refresh),
                        label: const Text('刷新信息'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _logSize > 0 ? _clearLogs : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('清除日志'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
