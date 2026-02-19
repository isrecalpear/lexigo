// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Page for viewing application logs.

/// Log viewer page showing recent log entries.
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
          _error = context.l10n.logPathNotFound;
          _loading = false;
        });
        return;
      }

      final File file = File(path);
      if (!await file.exists()) {
        setState(() {
          _content = '';
          _error = context.l10n.logEmpty;
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
        _error = context.l10n.logReadFailed('$e');
        _loading = false;
      });
    }
  }

  Future<void> _shareLog() async {
    // Share the log file using platform-specific sharing options

    // Linux system may not support file sharing, so we can show a message instead
    // TODO: Implement Linux-specific sharing if needed
    if (Platform.isLinux) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.logShareNotSupported)),
      );
      AppLogger.warning('Log sharing is not supported on Linux');
      return;
    }

    try {
      final String? path = await AppLogger.getCurrentLogFilePath();
      if (!mounted) return;

      if (path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.logFileNotFound)));
        AppLogger.warning('Failed to share log: log file not found');
        return;
      }

      final params = ShareParams(files: [XFile(path)]);

      final result = await SharePlus.instance.share(params);

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.logShareSuccess)));
        AppLogger.info('Log shared successfully');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.logShareFailed('$e'))),
      );
      AppLogger.error('Failed to share log', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.logViewTitle),
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
                          ? Center(child: Text(context.l10n.logEmpty))
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
