import 'package:flutter/material.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/pages/learning/learning_page.dart';
import 'package:lexigo/pages/widgets/word_card.dart';

class LearningSummarizePage extends StatefulWidget {
  const LearningSummarizePage({
    super.key,
    required this.wordsUnknown,
    required this.wordsLearned,
    required this.wordsReviewed,
    required this.wordsToReview,
    required this.heroTag,
  });

  final Word wordsUnknown;
  final int wordsLearned;
  final int wordsReviewed;
  final int wordsToReview;

  /// Hero animation tag for word card transition.
  final String heroTag;

  @override
  State<LearningSummarizePage> createState() => _LearningSummarizePageState();
}

class _LearningSummarizePageState extends State<LearningSummarizePage> {
  late Word _nextWord;
  late String _heroTag;

  @override
  void initState() {
    super.initState();
    _nextWord = widget.wordsUnknown;
    _heroTag = widget.heroTag;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).learningSummaryTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Text(
              AppLocalizations.of(context).learningSummaryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  AppLocalizations.of(context).learningSummary
                      .replaceAll('{learned}', '${widget.wordsLearned}')
                      .replaceAll('{reviewed}', '${widget.wordsReviewed}')
                      .replaceAll('{toReview}', '${widget.wordsToReview}'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).learningSummaryNextLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Hero(
              tag: _heroTag,
              flightShuttleBuilder:
                  (context, animation, direction, fromContext, toContext) {
                    return Material(
                      color: Colors.transparent,
                      child: toContext.widget,
                    );
                  },
              child: WordCard(
                word: _nextWord,
                onUpdated: (updated) {
                  setState(() {
                    _nextWord = updated;
                    _heroTag = 'word_${updated.originalWord}';
                  });
                },
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
                      AppLocalizations.of(context).learningSummaryEnd,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LearningPage(
                            word: _nextWord,
                            heroTag: _heroTag,
                            learningLanguage: _nextWord.sourceLanguageCode,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).learningSummaryNextGroup,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
