/// Page for editing an existing word.
///
/// Allows modifying all word fields and updating the word in the database.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/datas/orm/word_dao.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Word editor widget.
class WordEditPage extends StatefulWidget {
  const WordEditPage({super.key, required this.word, required this.card});

  final Word word;
  final fsrs.Card card;

  @override
  State<WordEditPage> createState() => _WordEditPageState();
}

/// State for WordEditPage that handles form submission and updates.
class _WordEditPageState extends State<WordEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _originalWordController;
  late final TextEditingController _translationController;
  late final TextEditingController _originalExampleController;
  late final TextEditingController _exampleTranslationController;
  late final TextEditingController _unitIdController;
  late final TextEditingController _bookIdController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _originalWordController = TextEditingController(
      text: widget.word.originalWord,
    );
    _translationController = TextEditingController(
      text: widget.word.translation,
    );
    _originalExampleController = TextEditingController(
      text: widget.word.originalExample,
    );
    _exampleTranslationController = TextEditingController(
      text: widget.word.exampleTranslation,
    );
    _unitIdController = TextEditingController(text: widget.word.unitID);
    _bookIdController = TextEditingController(text: widget.word.bookID);
    AppLogger.info('Entering edit word page: ${widget.word.originalWord}');
  }

  @override
  void dispose() {
    _originalWordController.dispose();
    _translationController.dispose();
    _originalExampleController.dispose();
    _exampleTranslationController.dispose();
    _unitIdController.dispose();
    _bookIdController.dispose();
    AppLogger.info('Leaving edit word page: ${widget.word.originalWord}');
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = Word(
        originalWord: _originalWordController.text.trim(),
        translation: _translationController.text.trim(),
        originalExample: _originalExampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim(),
        sourceLanguageCode: widget.word.sourceLanguageCode,
        card: Future.value(widget.card),
        unitID: _unitIdController.text.trim().isEmpty
            ? 'DefaultUnit'
            : _unitIdController.text.trim(),
        bookID: _bookIdController.text.trim().isEmpty
            ? 'DefaultBook'
            : _bookIdController.text.trim(),
      );

      final dao = await WordDao.open();
      await dao.updateWord(widget.word.sourceLanguageCode, updated);
      AppLogger.info('Word updated successfully: ${updated.originalWord}');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.editSuccess)));
      Navigator.pop<Word>(context, updated);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update word',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.editFailed('$e'))));
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
      appBar: AppBar(title: Text(context.l10n.editWordPageTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                onPressed: _isSaving ? null : _save,
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
