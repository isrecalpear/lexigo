/// Page for viewing and managing existing words in a language.
///
/// Displays words in a list with buttons to add, edit, or delete words.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/manager.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/settings.dart';

/// Word list viewer and manager.
class WordViewPage extends StatefulWidget {
  const WordViewPage({super.key});

  @override
  State<WordViewPage> createState() => _WordViewPageState();
}

class _WordViewPageState extends State<WordViewPage> {
  LanguageCode _languageCode = SettingsStore.instance.settings.learningLanguage;
  bool _isLoading = false;
  List<Word> _words = [];
  final _wordManager = WordManager();

  @override
  void initState() {
    super.initState();
    AppLogger.info('Entering word view page');
    _loadWords();
  }

  @override
  void dispose() {
    AppLogger.info('Leaving word view page');
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final words = await _wordManager.getWords(_languageCode);

      if (!mounted) return;
      setState(() {
        _words = words;
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load word list',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loadFailed('$e'))));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editWord(Word word) async {
    final updated = await Navigator.push<Word>(
      context,
      AppRoutes.wordEdit(word: word, card: word.card),
    );

    if (updated != null) {
      await _loadWords();
    }
  }

  Future<void> _deleteWord(Word word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.deleteWordTitle),
          content: Text(context.l10n.deleteWordConfirm(word.originalWord)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _wordManager.deleteWordsByCardId([word.card.cardId]);
      AppLogger.info('Deleted word successfully: ${word.originalWord}');
      await _loadWords();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.deleteSuccess)));
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete word',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.deleteFailed('$e'))),
        );
      }
    }
  }

  String _familiarityLabel(fsrs.Card card, BuildContext context) {
    switch (card.state) {
      case fsrs.State.learning:
        return context.l10n.familiarityLearning;
      case fsrs.State.relearning:
        return context.l10n.familiarityRelearning;
      case fsrs.State.review:
        return context.l10n.familiarityReview;
    }
  }

  Color _familiarityColor(fsrs.Card card, BuildContext context) {
    switch (card.state) {
      case fsrs.State.learning:
        return Theme.of(context).colorScheme.error;
      case fsrs.State.relearning:
        return Theme.of(context).colorScheme.tertiary;
      case fsrs.State.review:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.wordViewTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                AppRoutes.wordAdd(languageCode: _languageCode),
              );
              if (mounted) {
                await _loadWords();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<LanguageCode>(
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
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _languageCode = value;
                        });
                        _loadWords();
                      },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadWords,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _words.isEmpty
                    ? Center(child: Text(context.l10n.wordViewEmpty))
                    : ListView.separated(
                        itemCount: _words.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final word = _words[index];
                          final familiarity = _familiarityLabel(
                            word.card,
                            context,
                          );
                          final color = _familiarityColor(word.card, context);

                          return ListTile(
                            title: Text(word.originalWord),
                            subtitle: Text(word.originalTranslation),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(familiarity),
                                  backgroundColor: color.withValues(
                                    alpha: 0.15,
                                  ),
                                  labelStyle: TextStyle(color: color),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _editWord(word);
                                        break;
                                      case 'delete':
                                        _deleteWord(word);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(context.l10n.edit),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(context.l10n.delete),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            dense: false,
                            onTap: () {
                              AppLogger.debug(
                                'View word: ${word.originalWord}',
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
