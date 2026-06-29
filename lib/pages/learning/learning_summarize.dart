import 'package:flutter/material.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/pages/learning/learn.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/backend/word/global_provider.dart';

/// Summary page displayed after completing a learning session.

class LearningSummarizePage extends StatefulWidget {
  const LearningSummarizePage({
    super.key,
    required this.wordsUnknown,
    required this.wordsLearned,
    required this.wordsReviewed,
    required this.wordsToReview,
    required this.wordProvider,
  });

  final Word wordsUnknown;
  final int wordsLearned;
  final int wordsReviewed;
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
    final word = widget.wordProvider.currentWord;
    final noMoreWordsToLearn =
        word == null || widget.wordProvider.isFallbackWord;
    if (word == null) {
      widget.wordProvider.setFallbackWord();
    }
    Word displayWord = widget.wordProvider.currentWord!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.learningSummaryTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Text(
              AppLocalizations.of(context)!.learningSummaryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  AppLocalizations.of(context)!.learningSummary(
                    widget.wordsLearned,
                    widget.wordsReviewed,
                    widget.wordsToReview,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.learningSummaryNextLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Hero(
              tag: widget.wordProvider.heroTag,
              flightShuttleBuilder:
                  (context, animation, direction, fromContext, toContext) {
                    return Material(
                      color: Colors.transparent,
                      child: toContext.widget,
                    );
                  },
              child: WordCard(
                word: displayWord,
                onUpdated: (updated) {
                  widget.wordProvider.updateWord(updated);
                },
                maskTranslation: !noMoreWordsToLearn,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.learningSummaryEnd,
                    ),
                  ),
                ),
                if (!noMoreWordsToLearn) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LearningPage(
                              word: word,
                              learningLanguage: word.sourceLanguageCode,
                              wordProvider: widget.wordProvider,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.learningSummaryNextGroup,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
