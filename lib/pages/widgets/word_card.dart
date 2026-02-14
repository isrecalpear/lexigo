/// Reusable word card widget for displaying word information.
///
/// Displays original word, translation, example sentences with translations,
/// and provides a menu for marking words as correct or known.

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/word_provider.dart';
import 'package:lexigo/l10n/app_localizations.dart';

/// Displays a single word card with bilingual content.
class WordCard extends StatelessWidget {
  static const String _menuCorrect = 'correct';
  static const String _menuKnown = 'known';

  const WordCard({super.key, required this.word, this.onUpdated});

  /// The word to display.
  final Word word;

  /// Callback when word is updated (e.g., after editing).
  final ValueChanged<Word>? onUpdated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 140),
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
                      word.originalWord,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == _menuCorrect) {
                          signAsWrong(context);
                        } else if (value == _menuKnown) {
                          signAsKnown(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _menuCorrect,
                          child: Text(context.l10n.wordCardCorrect),
                        ),
                        PopupMenuItem(
                          value: _menuKnown,
                          child: Text(context.l10n.wordCardMarkKnown),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  word.translation,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Text(
                  word.originalExample,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  word.exampleTranslation,
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
    );
  }

  /// Marks the word as known (implementation pending).
  Future<void> signAsKnown(BuildContext context) async {
    final updated = await WordProvider().signAsKnown(context, word);
    if (updated != null) {
      onUpdated?.call(updated);
    }
  }

  /// Marks the word as wrong and opens the edit dialog.
  Future<void> signAsWrong(BuildContext context) async {
    final updated = await WordProvider().signAsWrong(context, word);
    if (updated != null) {
      onUpdated?.call(updated);
    }
  }
}
