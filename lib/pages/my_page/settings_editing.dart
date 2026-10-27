/// Page for editing application settings (locale, theme, color).
///
/// Allows users to customize UI language, theme mode (light/dark/system),
/// and theme color seed.
library;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_font.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/font_manager.dart';

/// Settings editor widget for locale, theme, color, and font customization.
class SettingsEditingPage extends StatefulWidget {
  const SettingsEditingPage({
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
  State<SettingsEditingPage> createState() => _SettingsEditingPageState();
}

/// State for SettingsEditingPage that manages setting UI and dialogs.
class _SettingsEditingPageState extends State<SettingsEditingPage> {
  late String _selectedLanguage;
  late ThemeMode _selectedThemeMode;
  late bool _useAutoColor;
  late Color _customColor;
  late AppFont _font;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageValueFromLocale(widget.locale);
    _selectedThemeMode = widget.themeMode;
    _useAutoColor = widget.colorSeed == null;
    _customColor = widget.colorSeed ?? AppTheme.defaultSeed;
    _font = widget.font;
  }

  @override
  void didUpdateWidget(covariant SettingsEditingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _selectedLanguage = _languageValueFromLocale(widget.locale);
    }
    if (oldWidget.themeMode != widget.themeMode) {
      _selectedThemeMode = widget.themeMode;
    }
    if (oldWidget.colorSeed != widget.colorSeed) {
      if (widget.colorSeed == null) {
        _useAutoColor = true;
      } else {
        _useAutoColor = false;
        _customColor = widget.colorSeed!;
      }
    }
    if (oldWidget.font != widget.font) {
      _font = widget.font;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsEditSettings)),
      body: SafeArea(
        child: AppContent(
          child: ListView(
            padding: AppInsets.formPage,
            children: <Widget>[
              AppSettingsGroup(
                title: l10n.sectionAppearance,
                children: <Widget>[
                  AppSettingsTile(
                    icon: Icons.language_rounded,
                    title: l10n.settingsLanguage,
                    subtitle: _currentLanguageLabel(context),
                    onTap: _openLanguagePicker,
                  ),
                  AppSettingsTile(
                    icon: Icons.brightness_6_outlined,
                    iconColor: colors.tertiary,
                    title: l10n.settingsTheme,
                    subtitle: _currentThemeLabel(context),
                    onTap: _openThemePicker,
                  ),
                  AppSettingsTile(
                    icon: Icons.color_lens_outlined,
                    iconColor: colors.secondary,
                    title: l10n.settingsThemeColor,
                    subtitle: _currentColorLabel(context),
                    trailing: _buildColorPreview(),
                    onTap: _openColorPicker,
                  ),
                  AppSettingsTile(
                    icon: Icons.font_download_outlined,
                    title: l10n.settingsFont,
                    subtitle: _fontLabel(context, _font),
                    onTap: _openFontPicker,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _languageValueFromLocale(Locale? locale) {
    if (locale == null) {
      return 'system';
    }
    return locale.languageCode;
  }

  String _currentLanguageLabel(BuildContext context) {
    switch (_selectedLanguage) {
      case 'system':
        return AppLocalizations.of(context)!.languageSystem;
      case 'zh':
        return AppLocalizations.of(context)!.languageChinese;
      case 'en':
      default:
        return AppLocalizations.of(context)!.languageEnglish;
    }
  }

  String _currentThemeLabel(BuildContext context) {
    switch (_selectedThemeMode) {
      case ThemeMode.light:
        return AppLocalizations.of(context)!.themeLight;
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.themeDark;
      case ThemeMode.system:
        return AppLocalizations.of(context)!.themeSystem;
    }
  }

  String _currentColorLabel(BuildContext context) {
    if (_useAutoColor) {
      return AppLocalizations.of(context)!.themeColorAuto;
    }

    final int rgb = _customColor.toARGB32() & 0xFFFFFF;
    final String hex = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
    return '#$hex';
  }

  /// Small trailing swatch that previews the active theme color.
  Widget _buildColorPreview() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = _useAutoColor ? colors.primary : _customColor;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: colors.outlineVariant, width: 1.5),
      ),
    );
  }

  void selectLanguage(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedLanguage = value;
    });

    if (value == 'system') {
      widget.onLocaleChanged(null);
      return;
    }

    final locale = Locale(value);
    widget.onLocaleChanged(locale);
  }

  void selectThemeMode(ThemeMode? mode) {
    if (mode == null) {
      return;
    }

    setState(() {
      _selectedThemeMode = mode;
    });

    widget.onThemeModeChanged(mode);
  }

  Future<void> _openColorPicker() async {
    final Color initial = _customColor;
    final _ColorSelection? picked = await _showColorPickerDialog(
      context,
      initial,
    );
    if (picked == null) {
      return;
    }

    if (picked.isAuto) {
      setState(() {
        _useAutoColor = true;
      });
      widget.onColorSeedChanged(null);
    } else {
      final Color color = picked.color;
      setState(() {
        _useAutoColor = false;
        _customColor = color;
      });
      widget.onColorSeedChanged(color);
    }
  }

  /// Shows the UI language picker as a rounded modal bottom sheet.
  Future<void> _openLanguagePicker() async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _PickerSheet(
          title: sheetContext.l10n.language,
          children: <Widget>[
            AppChoiceTile<String>(
              value: 'system',
              groupValue: _selectedLanguage,
              title: sheetContext.l10n.languageSystem,
              icon: Icons.settings_suggest_outlined,
              onSelected: (String value) => Navigator.pop(sheetContext, value),
            ),
            AppChoiceTile<String>(
              value: 'en',
              groupValue: _selectedLanguage,
              title: sheetContext.l10n.languageEnglish,
              icon: Icons.language_rounded,
              onSelected: (String value) => Navigator.pop(sheetContext, value),
            ),
            AppChoiceTile<String>(
              value: 'zh',
              groupValue: _selectedLanguage,
              title: sheetContext.l10n.languageChinese,
              icon: Icons.translate_rounded,
              onSelected: (String value) => Navigator.pop(sheetContext, value),
            ),
          ],
        );
      },
    );
    selectLanguage(result);
  }

  /// Shows the theme mode picker as a rounded modal bottom sheet.
  Future<void> _openThemePicker() async {
    final ThemeMode? result = await showModalBottomSheet<ThemeMode>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _PickerSheet(
          title: sheetContext.l10n.settingsTheme,
          children: <Widget>[
            AppChoiceTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _selectedThemeMode,
              title: sheetContext.l10n.themeSystem,
              icon: Icons.brightness_auto_rounded,
              onSelected: (ThemeMode value) =>
                  Navigator.pop(sheetContext, value),
            ),
            AppChoiceTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _selectedThemeMode,
              title: sheetContext.l10n.themeLight,
              icon: Icons.light_mode_rounded,
              onSelected: (ThemeMode value) =>
                  Navigator.pop(sheetContext, value),
            ),
            AppChoiceTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _selectedThemeMode,
              title: sheetContext.l10n.themeDark,
              icon: Icons.dark_mode_rounded,
              onSelected: (ThemeMode value) =>
                  Navigator.pop(sheetContext, value),
            ),
          ],
        );
      },
    );

    selectThemeMode(result);
  }

  String _fontLabel(BuildContext context, AppFont font) {
    switch (font) {
      case AppFont.system:
        return context.l10n.fontSystem;
      case AppFont.miSans:
        return context.l10n.fontMiSans;
      case AppFont.harmonyOS:
        return context.l10n.fontHarmonyOS;
    }
  }

  String _fontDescription(BuildContext context, AppFont font) {
    switch (font) {
      case AppFont.system:
        return context.l10n.fontSystemSubtitle;
      case AppFont.miSans:
        return context.l10n.fontMiSansSubtitle;
      case AppFont.harmonyOS:
        return context.l10n.fontHarmonyOSSubtitle;
    }
  }

  /// Shows the font picker as a rounded modal bottom sheet.
  Future<void> _openFontPicker() async {
    final AppFont? result = await showModalBottomSheet<AppFont>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _PickerSheet(
          title: sheetContext.l10n.fontPickerTitle,
          children: AppFont.values.map((AppFont font) {
            return AppChoiceTile<AppFont>(
              value: font,
              groupValue: _font,
              title: _fontLabel(sheetContext, font),
              subtitle: _fontDescription(sheetContext, font),
              onSelected: (AppFont value) => Navigator.pop(sheetContext, value),
            );
          }).toList(),
        );
      },
    );

    if (result == null || result == _font) {
      return;
    }
    await _applyFont(result);
  }

  /// Downloads (when needed) and activates [font].
  ///
  /// The settings callback is only invoked after the font has been registered
  /// with the engine, so the persisted selection always matches a usable font.
  Future<void> _applyFont(AppFont font) async {
    try {
      if (font.isSystem) {
        await FontManager.instance.loadFont(AppFont.system);
        if (!mounted) {
          return;
        }
        _selectFont(AppFont.system);
        return;
      }

      final bool installed = await FontManager.instance.isInstalled(font);
      if (!installed) {
        if (!mounted) {
          return;
        }
        final bool? confirmed = await _confirmFontDownload(font);
        if (confirmed != true || !mounted) {
          return;
        }
        await _downloadFont(font);
        if (!mounted) {
          return;
        }
      }

      final bool loaded = await FontManager.instance.loadFont(font);
      if (!mounted) {
        return;
      }
      if (!loaded) {
        // The cached files are unusable (corrupt or half-extracted). Drop them so
        // the next attempt downloads a fresh archive.
        await FontManager.instance.removeFont(font);
        if (!mounted) {
          return;
        }
        _showSnackBar(context.l10n.fontNotAvailable);
        return;
      }
      _selectFont(font);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to download or apply font ${font.storageId}',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      _showSnackBar(context.l10n.fontDownloadFailed('$error'));
    }
  }

  Future<bool?> _confirmFontDownload(AppFont font) {
    final String source = font.officialPageUrl ?? '';
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.fontDownloadTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.fontDownloadConfirm(
                  _fontLabel(context, font),
                  '${font.approximateSizeMb ?? ''}',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.fontOfficialSource,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SelectableText(
                source,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.fontLicenseHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
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
        );
      },
    );
  }

  /// Shows a blocking progress dialog while the official archive is downloaded.
  Future<void> _downloadFont(AppFont font) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    bool dialogOpen = true;
    StateSetter? setDialogState;
    double? progressFraction;
    String? progressLabel = context.l10n.fontDownloadPreparing;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              setDialogState = setState;
              return AlertDialog(
                title: Text(dialogContext.l10n.fontDownloadTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: progressFraction),
                    const SizedBox(height: 16),
                    Text(
                      progressLabel ?? dialogContext.l10n.fontDownloadPreparing,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    try {
      await FontManager.instance.installFont(
        font,
        onProgress: (int received, int? total) {
          if (!dialogOpen) {
            return;
          }
          setDialogState?.call(() {
            progressFraction = (total != null && total > 0)
                ? (received / total).clamp(0.0, 1.0).toDouble()
                : null;
            progressLabel = _downloadProgressLabel(context, received, total);
          });
        },
      );
    } finally {
      dialogOpen = false;
      if (navigator.mounted) {
        navigator.pop();
      }
    }
  }

  String _downloadProgressLabel(
    BuildContext context,
    int received,
    int? total,
  ) {
    if (total != null && total > 0) {
      final int percent = (received * 100 / total)
          .round()
          .clamp(0, 100)
          .toInt();
      return context.l10n.fontDownloading(
        '$percent',
        _formatMegabytes(received),
        _formatMegabytes(total),
      );
    }
    return context.l10n.fontDownloadingUnknown(_formatMegabytes(received));
  }

  String _formatMegabytes(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(1);
  }

  void _selectFont(AppFont font) {
    setState(() {
      _font = font;
    });
    widget.onFontChanged(font);
    _showSnackBar(context.l10n.fontApplied(_fontLabel(context, font)));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<_ColorSelection?> _showColorPickerDialog(
    BuildContext context,
    Color initial,
  ) async {
    HSVColor hsv = HSVColor.fromColor(initial);
    final TextEditingController hexController = TextEditingController(
      text: _colorToHex(hsv.toColor()),
    );
    bool isHexValid = true;
    bool useAuto = _useAutoColor;
    final _ColorSelection? selection = await showDialog<_ColorSelection>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colors = theme.colorScheme;
            final AppLocalizations l10n = context.l10n;
            final Color preview = useAuto ? colors.primary : hsv.toColor();
            return AlertDialog(
              title: Text(l10n.themeColorPickerTitle),
              content: SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 88,
                        decoration: BoxDecoration(
                          color: preview,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.themeColorAuto),
                        value: useAuto,
                        onChanged: (bool value) => setState(() {
                          useAuto = value;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: hexController,
                        decoration: InputDecoration(
                          labelText: l10n.themeColorHexLabel,
                          hintText: l10n.themeColorHexHint,
                          errorText: isHexValid
                              ? null
                              : l10n.themeColorHexInvalid,
                        ),
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: !useAuto,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-fA-F#]'),
                          ),
                        ],
                        onChanged: (String value) {
                          if (useAuto) {
                            return;
                          }
                          final Color? parsed = _parseHexColor(value);
                          setState(() {
                            isHexValid = parsed != null;
                            if (parsed != null) {
                              hsv = HSVColor.fromColor(parsed);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildSlider(
                        l10n.themeColorHue,
                        hsv.hue,
                        0,
                        360,
                        useAuto
                            ? null
                            : (double value) => setState(() {
                                hsv = hsv.withHue(value);
                                hexController.text = _colorToHex(hsv.toColor());
                                isHexValid = true;
                              }),
                        colors.primary,
                      ),
                      _buildSlider(
                        l10n.themeColorSaturation,
                        hsv.saturation,
                        0,
                        1,
                        useAuto
                            ? null
                            : (double value) => setState(() {
                                hsv = hsv.withSaturation(value);
                                hexController.text = _colorToHex(hsv.toColor());
                                isHexValid = true;
                              }),
                        colors.primary,
                      ),
                      _buildSlider(
                        l10n.themeColorBrightness,
                        hsv.value,
                        0,
                        1,
                        useAuto
                            ? null
                            : (double value) => setState(() {
                                hsv = hsv.withValue(value);
                                hexController.text = _colorToHex(hsv.toColor());
                                isHexValid = true;
                              }),
                        colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: (useAuto || isHexValid)
                      ? () => Navigator.pop(
                          context,
                          useAuto
                              ? const _ColorSelection.auto()
                              : _ColorSelection.custom(preview),
                        )
                      : null,
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
    hexController.dispose();
    return selection;
  }

  /// Builds a labelled slider tinted with the current picker color.
  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double>? onChanged,
    Color tint,
  ) {
    final ThemeData theme = Theme.of(context);
    final String valueLabel = max <= 1
        ? '${(value * 100).round()}%'
        : '${value.round()}°';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: tint,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    final int rgb = color.toARGB32() & 0xFFFFFF;
    final String hex = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
    return '#$hex';
  }

  Color? _parseHexColor(String input) {
    final String raw = input.trim();
    if (raw.isEmpty) {
      return null;
    }

    final String cleaned = raw.startsWith('#') ? raw.substring(1) : raw;
    if (cleaned.length != 6 && cleaned.length != 8) {
      return null;
    }

    final int? value = int.tryParse(cleaned, radix: 16);
    if (value == null) {
      return null;
    }

    if (cleaned.length == 6) {
      return Color(0xFF000000 | value);
    }

    return Color(value);
  }
}

/// Rounded bottom sheet listing mutually exclusive choices.
class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.title, required this.children});

  /// Sheet headline naming the setting being picked.
  final String title;

  /// Selectable rows rendered inside the sheet.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSelection {
  const _ColorSelection.auto() : isAuto = true, color = Colors.transparent;

  const _ColorSelection.custom(this.color) : isAuto = false;

  final bool isAuto;
  final Color color;
}
