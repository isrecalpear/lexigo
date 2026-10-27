/// Page for adding a new word to the database.
///
/// Provides form fields for word, translation, examples, unit ID, and book ID.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/settings.dart';

/// Form widget for adding words.
class WordAddPage extends StatefulWidget {
  final LanguageCode? languageCode;

  const WordAddPage({super.key, this.languageCode});

  @override
  State<WordAddPage> createState() => _WordAddPageState();
}

/// State for WordAddPage that handles form submission.
class _WordAddPageState extends State<WordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _originalWordController = TextEditingController();
  final _translationController = TextEditingController();
  final _originalExampleController = TextEditingController();
  final _exampleTranslationController = TextEditingController();
  final _unitIdController = TextEditingController(text: 'DefaultUnit');
  final _bookIdController = TextEditingController(text: 'DefaultBook');

  late LanguageCode _languageCode =
      widget.languageCode ?? SettingsStore.instance.settings.learningLanguage;
  bool _isSaving = false;

  final _wordManager = WordManager();

  @override
  void initState() {
    super.initState();
    AppLogger.info('Entering add word page');
  }

  @override
  void dispose() {
    _originalWordController.dispose();
    _translationController.dispose();
    _originalExampleController.dispose();
    _exampleTranslationController.dispose();
    _unitIdController.dispose();
    _bookIdController.dispose();
    AppLogger.info('Leaving add word page');
    super.dispose();
  }

  Future<void> _saveWord() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      AppLogger.debug(
        'Starting to save word: ${_originalWordController.text.trim()}',
      );
      final card = await fsrs.Card.create();
      final word = Word(
        originalWord: _originalWordController.text.trim(),
        originalTranslation: _translationController.text.trim(),
        exampleSentence: _originalExampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim(),
        sourceLanguageCode: _languageCode,
        card: card,
        unitID: _unitIdController.text.trim().isEmpty
            ? 'DefaultUnit'
            : _unitIdController.text.trim(),
        bookID: _bookIdController.text.trim().isEmpty
            ? 'DefaultBook'
            : _bookIdController.text.trim(),
      );

      await _wordManager.insertWord(word);
      AppLogger.info('Word saved successfully: ${word.originalWord}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addSuccess)),
        );
        form.reset();
        _originalWordController.clear();
        _translationController.clear();
        _originalExampleController.clear();
        _exampleTranslationController.clear();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save word', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addFailed('$e')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.required;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addWordPageTitle)),
      body: SafeArea(
        child: AppContent(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: AppInsets.formPage,
              children: <Widget>[
                AppSectionHeader(title: l10n.sectionWords),
                AppSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButtonFormField<LanguageCode>(
                        initialValue: _languageCode,
                        decoration: InputDecoration(
                          labelText: l10n.fieldLanguage,
                          prefixIcon: const Icon(Icons.translate_rounded),
                        ),
                        items: LanguageCode.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(_languageName(context, item)),
                              ),
                            )
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  _languageCode = value;
                                });
                              },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _originalWordController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldOriginal,
                          prefixIcon: const Icon(Icons.text_fields_rounded),
                        ),
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _translationController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldTranslation,
                          prefixIcon: const Icon(Icons.translate_rounded),
                        ),
                        validator: _requiredValidator,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppSectionHeader(title: l10n.fieldOriginalExample),
                AppSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _originalExampleController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldOriginalExample,
                          alignLabelWithHint: true,
                        ),
                        validator: _requiredValidator,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _exampleTranslationController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldExampleTranslation,
                          alignLabelWithHint: true,
                        ),
                        validator: _requiredValidator,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Unit / book IDs are optional grouping metadata, kept in their
                // own card so the main content stays focused.
                AppSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: _unitIdController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldUnitId,
                          prefixIcon: const Icon(Icons.folder_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _bookIdController,
                        decoration: InputDecoration(
                          labelText: l10n.fieldBookId,
                          prefixIcon: const Icon(Icons.menu_book_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveWord,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Localized display name of [code].
String _languageName(BuildContext context, LanguageCode code) {
  return switch (code) {
    LanguageCode.ko => context.l10n.languageKoreanName,
    LanguageCode.ru => context.l10n.languageRussianName,
    LanguageCode.en => context.l10n.languageEnglishName,
  };
}
