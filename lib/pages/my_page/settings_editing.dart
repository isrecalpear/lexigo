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

/// Settings editor widget for locale, theme, and color customization.
class SettingsEditingPage extends StatefulWidget {
  const SettingsEditingPage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.colorSeed,
    required this.onColorSeedChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Color? colorSeed;
  final ValueChanged<Color?> onColorSeedChanged;
  @override
  State<SettingsEditingPage> createState() => _SettingsEditingPageState();
}

/// State for SettingsEditingPage that manages setting UI and dialogs.
class _SettingsEditingPageState extends State<SettingsEditingPage> {
  late String _selectedLanguage;
  late ThemeMode _selectedThemeMode;
  late bool _useAutoColor;
  late Color _customColor;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageValueFromLocale(widget.locale);
    _selectedThemeMode = widget.themeMode;
    _useAutoColor = widget.colorSeed == null;
    _customColor = widget.colorSeed ?? Colors.blue;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsEditSettings),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.settingsLanguage),
              subtitle: Text(_currentLanguageLabel(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openLanguagePicker,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: Text(AppLocalizations.of(context)!.settingsTheme),
              subtitle: Text(_currentThemeLabel(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openThemePicker,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(AppLocalizations.of(context)!.settingsThemeColor),
              subtitle: Text(_currentColorLabel(context)),
              trailing: _buildColorPreview(),
              onTap: _openColorPicker,
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
          title: Text(AppLocalizations.of(context)!.language),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'system'),
              child: Text(AppLocalizations.of(context)!.languageSystem),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'en'),
              child: Text(AppLocalizations.of(context)!.languageEnglish),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'zh'),
              child: Text(AppLocalizations.of(context)!.languageChinese),
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
          title: Text(AppLocalizations.of(context)!.settingsTheme),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.system),
              child: Text(AppLocalizations.of(context)!.themeSystem),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.light),
              child: Text(AppLocalizations.of(context)!.themeLight),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ThemeMode.dark),
              child: Text(AppLocalizations.of(context)!.themeDark),
            ),
          ],
        );
      },
    );

    selectThemeMode(result);
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
              title: Text(AppLocalizations.of(context)!.themeColorPickerTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.themeColorAuto),
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
                      labelText: AppLocalizations.of(
                        context,
                      )!.themeColorHexLabel,
                      hintText: AppLocalizations.of(context)!.themeColorHexHint,
                      errorText: isHexValid
                          ? null
                          : AppLocalizations.of(context)!.themeColorHexInvalid,
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
                    AppLocalizations.of(context)!.themeColorHue,
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
                    AppLocalizations.of(context)!.themeColorSaturation,
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
                    AppLocalizations.of(context)!.themeColorBrightness,
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
                  child: Text(AppLocalizations.of(context)!.cancel),
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
                  child: Text(AppLocalizations.of(context)!.confirm),
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
