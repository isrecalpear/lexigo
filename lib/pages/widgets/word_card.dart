/// Reusable word card widget for displaying word information.
///
/// Shows the word, its translation and the example sentence pair on a tonal
/// container surface. The translation can be obscured, which turns the card
/// into a recall prompt for the learning flow; tapping the card (or the action
/// below it) reveals the answer.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Displays a single word card with bilingual content.
class WordCard extends StatelessWidget {
  /// Menu entry that opens the word editor ("correct this word").
  static const String _menuCorrect = 'correct';

  /// Menu entry that marks the word as known.
  static const String _menuKnown = 'known';

  /// Creates a word card.
  const WordCard({
    super.key,
    required this.word,
    this.onUpdated,
    this.obscured = false,
    this.onToggleObscured,
  });

  /// The word to display.
  final Word word;

  /// Callback when word is updated (e.g., after editing).
  final ValueChanged<Word>? onUpdated;

  /// Whether the translation (and example translation) is hidden.
  final bool obscured;

  /// Called when the user taps the card to reveal/hide the translation.
  final VoidCallback? onToggleObscured;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color content = colors.onPrimaryContainer;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 196, maxWidth: 640),
        child: AppSurface(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          onTap: onToggleObscured,
          semanticLabel: word.originalWord,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppPill(
                    label: word.sourceLanguageCode.name.toUpperCase(),
                    color: colors.onSecondaryContainer,
                    backgroundColor: colors.secondaryContainer,
                  ),
                  const Spacer(),
                  if (word.card.lastReview == null)
                    IconButton(
                      tooltip: word.card.cardId > 0
                          ? context.l10n.newWordHint
                          : context.l10n.newWordHintEasterEgg,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              showCloseIcon: true,
                              content: Text(
                                word.card.cardId > 0
                                    ? context.l10n.newWordHint
                                    : context.l10n.newWordHintEasterEgg,
                              ),
                            ),
                          ),
                      icon: Icon(
                        word.card.cardId > 0
                            ? Icons.fiber_new_rounded
                            : Icons.favorite_rounded,
                        color: content,
                      ),
                    ),
                  PopupMenuButton<String>(
                    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                    onSelected: (String value) {
                      if (value == _menuCorrect) {
                        signAsWrong(context);
                      } else if (value == _menuKnown) {
                        signAsKnown(context);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: _menuCorrect,
                            child: Text(context.l10n.wordCardCorrect),
                          ),
                          PopupMenuItem<String>(
                            value: _menuKnown,
                            child: Text(context.l10n.wordCardMarkKnown),
                          ),
                        ],
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: content,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                word.originalWord,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: content,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.curve,
                switchOutCurve: AppMotion.curve,
                child: obscured
                    ? Row(
                        key: const ValueKey<String>('masked'),
                        children: <Widget>[
                          Text(
                            '••••••',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: content,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.visibility_off_rounded,
                            size: 18,
                            color: content,
                          ),
                        ],
                      )
                    : Text(
                        word.originalTranslation,
                        key: const ValueKey<String>('translation'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: content,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
              ),
              if (onToggleObscured != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                TextButton.icon(
                  onPressed: onToggleObscured,
                  style: TextButton.styleFrom(
                    foregroundColor: content,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 40),
                    textStyle: theme.textTheme.labelMedium,
                  ),
                  icon: Icon(
                    obscured
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 18,
                  ),
                  label: Text(
                    obscured
                        ? context.l10n.showAnswer
                        : context.l10n.hideAnswer,
                  ),
                ),
              ],
              if (word.exampleSentence.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Divider(color: colors.outlineVariant, height: 1),
                const SizedBox(height: AppSpacing.md),
                Text(
                  word.exampleSentence,
                  style: theme.textTheme.bodyLarge?.copyWith(color: content),
                ),
                if (word.exampleTranslation.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  AnimatedSwitcher(
                    duration: AppMotion.medium,
                    child: obscured
                        ? Text(
                            '••••••••',
                            key: const ValueKey<String>('example-masked'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: content,
                              letterSpacing: 2,
                            ),
                          )
                        : Text(
                            word.exampleTranslation,
                            key: const ValueKey<String>('example'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: content,
                            ),
                          ),
                  ),
                ],
              ],
            ],
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.verified_rounded, size: 28),
          title: Text(context.l10n.wordCardMarkKnownTitle),
          content: Text(
            context.l10n.wordCardMarkKnownConfirm(word.originalWord),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.confirm),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    AppLogger.info('Marking as known: ${word.originalWord}');
    // TODO: Actually mark the word as known in the database
    // final repo = await WordRepository.open();
    // await repo.reviewWord(widget.word, Rating.easy);
    // final updatedWord = ...;
    // widget.onUpdated?.call(updatedWord);
  }

  /// Marks the word as wrong and opens the edit dialog.
  Future<void> signAsWrong(BuildContext context) async {
    if (!context.mounted) return;
    final Word? updated = await Navigator.push<Word>(
      context,
      AppRoutes.wordEdit(word: word, card: word.card),
    );
    if (updated != null) {
      onUpdated?.call(updated);
    }
  }
}
