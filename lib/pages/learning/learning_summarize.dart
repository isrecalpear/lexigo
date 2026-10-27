/// Summary page displayed after completing a learning session.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/theme/app_theme.dart';

/// Summary page displayed after completing a learning session.
class LearningSummarizePage extends StatefulWidget {
  /// Creates the session summary page.
  const LearningSummarizePage({
    super.key,
    required this.wordsUnknown,
    required this.wordsLearned,
    required this.wordsReviewed,
    required this.wordsToReview,
    required this.wordProvider,
  });

  /// The next word that will be shown after the summary.
  final Word wordsUnknown;

  /// Number of words learned in the finished session.
  final int wordsLearned;

  /// Number of words reviewed in the finished session.
  final int wordsReviewed;

  /// Number of words still waiting for review.
  final int wordsToReview;

  /// Centralized word state shared across the learning flow.
  final WordProvider wordProvider;

  @override
  State<LearningSummarizePage> createState() => _LearningSummarizePageState();
}

class _LearningSummarizePageState extends State<LearningSummarizePage> {
  @override
  void initState() {
    super.initState();
    widget.wordProvider.addListener(_onWordChanged);
  }

  @override
  void dispose() {
    widget.wordProvider.removeListener(_onWordChanged);
    super.dispose();
  }

  void _onWordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Word? word = widget.wordProvider.currentWord;
    final bool noMoreWordsToLearn =
        word == null || widget.wordProvider.isFallbackWord;
    if (word == null) {
      widget.wordProvider.setFallbackWord();
    }
    final Word displayWord = widget.wordProvider.currentWord!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningSummaryTitle)),
      body: SafeArea(
        top: false,
        child: AppContent(
          maxWidth: 720,
          child: ListView(
            padding: AppInsets.page,
            children: <Widget>[
              _SummaryHero(
                learned: widget.wordsLearned,
                reviewed: widget.wordsReviewed,
                toReview: widget.wordsToReview,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(title: l10n.learningSummaryNextLabel),
              WordCard(
                word: displayWord,
                obscured: false,
                onUpdated: (Word updated) {
                  widget.wordProvider.updateWord(updated);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((Route<dynamic> route) => route.isFirst);
                      },
                      child: Text(l10n.learningSummaryEnd),
                    ),
                  ),
                  if (!noMoreWordsToLearn) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            AppRoutes.learning(
                              word: word,
                              languageCode: word.sourceLanguageCode,
                              wordProvider: widget.wordProvider,
                            ),
                          );
                        },
                        child: Text(l10n.learningSummaryNextGroup),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
      backgroundColor: colors.surface,
    );
  }
}

/// Celebratory card shown at the top of the session summary.
class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.learned,
    required this.reviewed,
    required this.toReview,
  });

  final int learned;
  final int reviewed;
  final int toReview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color content = colors.onPrimaryContainer;
    final AppLocalizations l10n = context.l10n;
    return AppSurface(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration_rounded,
                  color: colors.onSecondaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _SummaryStat(
                        value: learned,
                        label: l10n.summaryLearned,
                        color: content,
                      ),
                    ),
                    Expanded(
                      child: _SummaryStat(
                        value: reviewed,
                        label: l10n.summaryReviewed,
                        color: content,
                      ),
                    ),
                    Expanded(
                      child: _SummaryStat(
                        value: toReview,
                        label: l10n.summaryToReview,
                        color: content,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single number + label column inside the summary hero.
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$value',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}
