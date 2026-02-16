/// Page for adding a new word to the database.
///
/// Provides form fields for word, translation, examples, unit ID, and book ID.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/datas/orm/word_dao.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/utils/app_logger.dart';

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

  late LanguageCode _languageCode = widget.languageCode ?? LanguageCode.en;
  bool _isSaving = false;

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
      final card = fsrs.Card.create();
      final word = Word(
        originalWord: _originalWordController.text.trim(),
        translation: _translationController.text.trim(),
        originalExample: _originalExampleController.text.trim(),
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

      final dao = await WordDao.open();
      await dao.insertWords(_languageCode, [word]);
      AppLogger.info('Word saved successfully: ${word.originalWord}');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.addSuccess)));
        form.reset();
        _originalWordController.clear();
        _translationController.clear();
        _originalExampleController.clear();
        _exampleTranslationController.clear();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save word', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.addFailed('$e'))));
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
      return context.l10n.required;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addWordPageTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<LanguageCode>(
                initialValue: _languageCode,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldLanguage,
                  border: const OutlineInputBorder(),
                ),
                items: LanguageCode.values
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item.name)),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _originalWordController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldOriginal,
                  border: const OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _translationController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldTranslation,
                  border: const OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originalExampleController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldOriginalExample,
                  border: const OutlineInputBorder(),
                ),
                validator: _requiredValidator,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exampleTranslationController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldExampleTranslation,
                  border: const OutlineInputBorder(),
                ),
                validator: _requiredValidator,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitIdController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldUnitId,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookIdController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldBookId,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveWord,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
