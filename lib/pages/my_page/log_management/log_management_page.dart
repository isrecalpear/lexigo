// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/my_page/log_management/log_view_page.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Log management page
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
      AppLogger.debug('Loaded log info: size=${size.toStringAsFixed(2)}MB');
    } catch (e) {
      AppLogger.error('Failed to load log info', error: e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.logClearConfirmTitle),
        content: Text(context.l10n.logClearConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.confirm),
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
          ).showSnackBar(SnackBar(content: Text(context.l10n.logCleared)));
          await _loadLogInfo();
        }
      } catch (e) {
        AppLogger.error('Failed to clear logs', error: e);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(content: Text(context.l10n.clearFailed('$e'))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.logManagementTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.l10n.logSizeTitle),
                  subtitle: Text('${_logSize.toStringAsFixed(2)} MB'),
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(context.l10n.logViewTitle),
                  subtitle: Text(context.l10n.logViewSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    AppLogger.info('Opening log view page');
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
                  title: Text(context.l10n.logAboutTitle),
                  subtitle: Text(context.l10n.logAboutSubtitle),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _loadLogInfo,
                        icon: const Icon(Icons.refresh),
                        label: Text(context.l10n.refreshInfo),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _logSize > 0 ? _clearLogs : null,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(context.l10n.clearLogs),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
