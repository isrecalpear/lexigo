/// Log viewer page showing recent log entries.
///
/// Renders the current day's log file as selectable monospace text and offers
/// refresh / share actions.
library;

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/device_info.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLog() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final String? path = await AppLogger.getCurrentLogFilePath();

      if (!mounted) return;
      if (path == null) {
        setState(() {
          _content = '';
          _error = AppLocalizations.of(context)!.logPathNotFound;
          _loading = false;
        });
        return;
      }

      final File file = File(path);
      if (!await file.exists()) {
        if (!mounted) return;
        setState(() {
          _content = '';
          _error = AppLocalizations.of(context)!.logEmpty;
          _loading = false;
        });
        return;
      }

      final String text = await file.readAsString();
      if (!mounted) return;
      setState(() {
        _content = text;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _content = '';
        _error = AppLocalizations.of(context)!.logReadFailed('$e');
        _loading = false;
      });
    }
  }

  Future<void> _shareLog() async {
    // Share the log file using platform-specific sharing options

    // Linux system may not support file sharing, so we can show a message instead
    // TODO: Implement Linux-specific sharing if needed
    final deviceInfo = DeviceInfoManager();
    if (!deviceInfo.supportsFileSharing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logShareNotSupported),
        ),
      );
      AppLogger.warning('Log sharing is not supported on Linux');
      return;
    }

    try {
      final String? path = await AppLogger.getCurrentLogFilePath();
      if (!mounted) return;

      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.logFileNotFound),
          ),
        );
        AppLogger.warning('Failed to share log: log file not found');
        return;
      }

      final params = ShareParams(files: [XFile(path)]);

      final result = await SharePlus.instance.share(params);

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.logShareSuccess),
          ),
        );
        AppLogger.info('Log shared successfully');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logShareFailed('$e')),
        ),
      );
      AppLogger.error('Failed to share log', error: e);
    }
  }

  /// Builds the body for the current loading / error / content state.
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_loading) {
      return const AppLoading();
    }
    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: _error!,
            action: FilledButton.tonal(
              onPressed: _loadLog,
              child: Text(l10n.refreshInfo),
            ),
          ),
        ),
      );
    }
    if (_content.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: AppEmptyState(
            icon: Icons.notes_rounded,
            title: l10n.logEmpty,
            message: l10n.logViewSubtitle,
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return SizedBox.expand(
      child: AppSurface(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SelectableText(
              _content,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logViewTitle),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadLog,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refreshInfo,
          ),
          if (DeviceInfoManager().supportsFileSharing)
            IconButton(
              onPressed: _shareLog,
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: AppContent(
          child: Padding(
            padding: AppInsets.formPage,
            child: _buildBody(context, l10n),
          ),
        ),
      ),
    );
  }
}
