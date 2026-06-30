/// Reusable word card widget for displaying word information.
///
/// Displays original word, translation, example sentences with translations,
/// and provides a menu for marking words as correct or known.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/my_page/word_management/word_edit.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Displays a single word card with bilingual content.
class WordCard extends StatefulWidget {
  static const String _menuCorrect = 'correct';
  static const String _menuKnown = 'known';

  const WordCard({
    super.key,
    required this.word,
    this.onUpdated,
    this.maskTranslation = false,
  });

  /// The word to display.
  final Word word;

  /// Callback when word is updated (e.g., after editing).
  final ValueChanged<Word>? onUpdated;

  /// Set if the translation is masked.
  final bool maskTranslation;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  late bool _maskTranslation;

  @override
  void initState() {
    super.initState();
    _maskTranslation = widget.maskTranslation;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 140, maxWidth: 640),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              shadowColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.word.originalWord,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                          textAlign: TextAlign.left,
                        ),
                        const Spacer(),
                        if (widget.word.card.lastReview == null)
                          IconButton(
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    showCloseIcon: true,
                                    content: Text(
                                      widget.word.card.cardId > 0
                                          ? AppLocalizations.of(
                                              context,
                                            )!.newWordHint
                                          : AppLocalizations.of(
                                              context,
                                            )!.newWordHintEasterEgg,
                                    ),
                                  ),
                                ),
                            icon: Icon(
                              widget.word.card.cardId > 0
                                  ? Icons.fiber_new
                                  : Icons.favorite,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == WordCard._menuCorrect) {
                              signAsWrong(context);
                            } else if (value == WordCard._menuKnown) {
                              signAsKnown(context);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: WordCard._menuCorrect,
                              child: Text(
                                AppLocalizations.of(context)!.wordCardCorrect,
                              ),
                            ),
                            PopupMenuItem(
                              value: WordCard._menuKnown,
                              child: Text(
                                AppLocalizations.of(context)!.wordCardMarkKnown,
                              ),
                            ),
                          ],
                          icon: Icon(
                            Icons.more_vert_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _maskTranslation
                          ? "***"
                          : widget.word.originalTranslation,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.word.exampleSentence,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      _maskTranslation ? "***" : widget.word.exampleTranslation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Marks the word as known in FSRS scheduling.
  ///
  /// TODO: Complete the implementation:
  /// - Mark the card as known by reviewing with Rating.easy
  /// - Update the database via WordRepository.reviewWord()
  /// - Trigger UI refresh via onUpdated callback
  Future<void> signAsKnown(BuildContext context) async {
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(dialogContext)!.wordCardMarkKnownTitle,
          ),
          content: Text(
            AppLocalizations.of(
              dialogContext,
            )!.wordCardMarkKnownConfirm(widget.word.originalWord),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(AppLocalizations.of(dialogContext)!.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    AppLogger.info('Marking as known: ${widget.word.originalWord}');
    // TODO: Actually mark the word as known in the database
    // final repo = await WordRepository.open();
    // await repo.reviewWord(widget.word, Rating.easy);
    // final updatedWord = ...;
    // widget.onUpdated?.call(updatedWord);
  }

  /// Marks the word as wrong and opens the edit dialog.
  Future<void> signAsWrong(BuildContext context) async {
    final card = widget.word.card;
    if (!context.mounted) return;
    final updated = await Navigator.push<Word>(
      context,
      MaterialPageRoute(
        builder: (context) => WordEditPage(word: widget.word, card: card),
      ),
    );
    if (updated != null) {
      widget.onUpdated?.call(updated);
    }
  }

  void setTranslationMasked() {
    setState(() {
      _maskTranslation = true;
    });
  }

  void setTranslationUnmasked() {
    setState(() {
      _maskTranslation = false;
    });
  }
}
