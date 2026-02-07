// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:lexigo/utils/app_logger.dart';

class LogViewPage extends StatefulWidget {
  const LogViewPage({super.key});

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  bool _loading = true;
  String _content = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final String? path = await AppLogger.getCurrentLogFilePath();

      if (path == null) {
        setState(() {
          _content = '';
          _error = '未找到日志路径';
          _loading = false;
        });
        return;
      }

      final File file = File(path);
      if (!await file.exists()) {
        setState(() {
          _content = '';
          _error = '暂无日志';
          _loading = false;
        });
        return;
      }

      final String text = await file.readAsString();
      setState(() {
        _content = text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _content = '';
        _error = '读取日志失败: $e';
        _loading = false;
      });
    }
  }

  Future<void> _shareLog() async {
    // Share the log file using platform-specific sharing options

    // Linux system may not support file sharing, so we can show a message instead
    // TODO: Implement Linux-specific sharing if needed
    if (Platform.isLinux) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Linux 系统暂不支持日志分享')));
      AppLogger.warning('分享日志失败: Linux 系统暂不支持日志分享');
      return;
    }

    try {
      final String? path = await AppLogger.getCurrentLogFilePath();
      if (!mounted) return;

      if (path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('未找到日志文件')));
        AppLogger.warning('分享日志失败: 未找到日志文件');
        return;
      }

      final params = ShareParams(files: [XFile(path)]);

      final result = await SharePlus.instance.share(params);

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('日志已分享')));
        AppLogger.info('日志已分享');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('分享日志失败: $e')));
      AppLogger.error('分享日志失败', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志查看'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadLog,
            icon: const Icon(Icons.refresh),
          ),
          if (!Platform.isLinux)
            IconButton(
              onPressed: _shareLog,
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _error != null
                          ? Center(child: Text(_error!))
                          : _content.isEmpty
                          ? const Center(child: Text('暂无日志'))
                          : SingleChildScrollView(
                              child: SelectableText(
                                _content,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
