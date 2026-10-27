/// Log file management interface.
///
/// Provides options to view logs, clear logs, and share logs.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Log management menu page.
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
      if (!mounted) return;
      setState(() {
        _logSize = size;
        _isLoading = false;
      });
      AppLogger.debug('Loaded log info: size=${size.toStringAsFixed(2)}MB');
    } catch (e) {
      AppLogger.error('Failed to load log info', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.delete_sweep_outlined,
            size: 28,
            color: colors.error,
          ),
          title: Text(AppLocalizations.of(context)!.logClearConfirmTitle),
          content: Text(AppLocalizations.of(context)!.logClearConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await AppLogger.clearAllLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.logCleared)),
          );
          await _loadLogInfo();
        }
      } catch (e) {
        AppLogger.error('Failed to clear logs', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.clearFailed('$e')),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.logManagementTitle)),
      body: SafeArea(
        child: AppContent(
          child: ListView(
            padding: AppInsets.formPage,
            children: <Widget>[
              AppSettingsGroup(
                title: l10n.sectionData,
                children: <Widget>[
                  // Storage figure: the app owns the log directory, so the size
                  // is informational only and therefore not tappable.
                  AppSettingsTile(
                    icon: Icons.sd_storage_outlined,
                    title: l10n.logSizeTitle,
                    trailing: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AppPill(
                            label: '${_logSize.toStringAsFixed(2)} MB',
                            icon: Icons.storage_rounded,
                          ),
                  ),
                  AppSettingsTile(
                    icon: Icons.article_outlined,
                    title: l10n.logViewTitle,
                    subtitle: l10n.logViewSubtitle,
                    onTap: () {
                      AppLogger.info('Opening log view page');
                      Navigator.push(context, AppRoutes.logView());
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Short explainer for the retention policy, on a tonal surface.
              AppSurface(
                color: colors.secondaryContainer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppIconBadge(
                      icon: Icons.info_outline_rounded,
                      color: colors.onSecondaryContainer,
                      size: 40,
                      iconSize: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.logAboutTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.logAboutSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSecondaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _loadLogInfo,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        l10n.refreshInfo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _logSize > 0 ? _clearLogs : null,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        l10n.clearLogs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
