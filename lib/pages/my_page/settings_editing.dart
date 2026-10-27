/// Page for editing application settings (locale, theme, color).
///
/// Allows users to customize UI language, theme mode (light/dark/system),
/// and theme color seed.
library;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';
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
    _customColor = widget.colorSeed ?? Colors.blue;
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsEditSettings)),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(context.l10n.settingsLanguage),
              subtitle: Text(_currentLanguageLabel(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openLanguagePicker,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: Text(context.l10n.settingsTheme),
              subtitle: Text(_currentThemeLabel(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openThemePicker,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(context.l10n.settingsThemeColor),
              subtitle: Text(_currentColorLabel(context)),
              trailing: _buildColorPreview(),
              onTap: _openColorPicker,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.font_download_outlined),
              title: Text(context.l10n.settingsFont),
              subtitle: Text(_fontLabel(context, _font)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openFontPicker,
            ),
          ],
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
        return context.l10n.languageSystem;
      case 'zh':
        return context.l10n.languageChinese;
      case 'en':
      default:
        return context.l10n.languageEnglish;
    }
  }

  String _currentThemeLabel(BuildContext context) {
    switch (_selectedThemeMode) {
      case ThemeMode.light:
        return context.l10n.themeLight;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      case ThemeMode.system:
        return context.l10n.themeSystem;
    }
  }

  String _currentColorLabel(BuildContext context) {
    if (_useAutoColor) {
      return context.l10n.themeColorAuto;
    }

    final int rgb = _customColor.toARGB32() & 0xFFFFFF;
    final String hex = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
    return '#$hex';
  }

  Widget _buildColorPreview() {
    final Color color = _useAutoColor
        ? Theme.of(context).colorScheme.primary
        : _customColor;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
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

  Future<void> _openLanguagePicker() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.language),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'system'),
              child: Text(context.l10n.languageSystem),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'en'),
              child: Text(context.l10n.languageEnglish),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'zh'),
              child: Text(context.l10n.languageChinese),
            ),
          ],
        );
      },
    );
    selectLanguage(result);
  }

  Future<void> _openThemePicker() async {
    final ThemeMode? result = await showDialog<ThemeMode>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.settingsTheme),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.system),
              child: Text(context.l10n.themeSystem),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.light),
              child: Text(context.l10n.themeLight),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.dark),
              child: Text(context.l10n.themeDark),
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

  Future<void> _openFontPicker() async {
    final AppFont? result = await showDialog<AppFont>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.fontPickerTitle),
          children: AppFont.values.map((AppFont font) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, font),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_fontLabel(context, font)),
                subtitle: Text(_fontDescription(context, font)),
                trailing: font == _font ? const Icon(Icons.check) : null,
              ),
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
  ) {
    HSVColor hsv = HSVColor.fromColor(initial);
    final TextEditingController hexController = TextEditingController(
      text: _colorToHex(hsv.toColor()),
    );
    bool isHexValid = true;
    bool useAuto = _useAutoColor;
    return showDialog<_ColorSelection>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final Color preview = useAuto
                ? Theme.of(context).colorScheme.primary
                : hsv.toColor();
            return AlertDialog(
              title: Text(context.l10n.themeColorPickerTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.themeColorAuto),
                    value: useAuto,
                    onChanged: (value) => setState(() {
                      useAuto = value;
                    }),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: preview,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hexController,
                    decoration: InputDecoration(
                      labelText: context.l10n.themeColorHexLabel,
                      hintText: context.l10n.themeColorHexHint,
                      errorText: isHexValid
                          ? null
                          : context.l10n.themeColorHexInvalid,
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: !useAuto,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9a-fA-F#]'),
                      ),
                    ],
                    onChanged: (value) {
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
                  const SizedBox(height: 16),
                  _buildSlider(
                    context.l10n.themeColorHue,
                    hsv.hue,
                    0,
                    360,
                    useAuto
                        ? null
                        : (value) => setState(() {
                            hsv = hsv.withHue(value);
                            hexController.text = _colorToHex(hsv.toColor());
                            isHexValid = true;
                          }),
                  ),
                  _buildSlider(
                    context.l10n.themeColorSaturation,
                    hsv.saturation,
                    0,
                    1,
                    useAuto
                        ? null
                        : (value) => setState(() {
                            hsv = hsv.withSaturation(value);
                            hexController.text = _colorToHex(hsv.toColor());
                            isHexValid = true;
                          }),
                  ),
                  _buildSlider(
                    context.l10n.themeColorBrightness,
                    hsv.value,
                    0,
                    1,
                    useAuto
                        ? null
                        : (value) => setState(() {
                            hsv = hsv.withValue(value);
                            hexController.text = _colorToHex(hsv.toColor());
                            isHexValid = true;
                          }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.cancel),
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
                  child: Text(context.l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double>? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
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

class _ColorSelection {
  const _ColorSelection.auto() : isAuto = true, color = Colors.transparent;

  const _ColorSelection.custom(this.color) : isAuto = false;

  final bool isAuto;
  final Color color;
}
