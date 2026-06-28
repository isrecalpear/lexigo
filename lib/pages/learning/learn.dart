/// Interactive learning page where users rate their knowledge of words.
///
/// Displays words one at a time with four rating options (Again, Hard, Good, Easy).
/// Updates FSRS scheduling based on ratings and loads the next word.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/learning/learning_summarize.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

/// Interactive learning widget for studying individual words.
class LearningPage extends StatefulWidget {
  const LearningPage({
    super.key,
    required this.word,
    required this.learningLanguage,
    required this.wordProvider,
  });

  /// The word being studied.
  final Word word;

  /// The currently selected learning language.
  final LanguageCode learningLanguage;

  /// Centralized word state shared across the learning flow.
  final WordProvider wordProvider;

  @override
  State<LearningPage> createState() => _LearningPageState();
}

/// State for LearningPage that manages word progression and scheduling.
class _LearningPageState extends State<LearningPage> {
  int _learnedCount = 0;

  /// TODO: Make session length configurable in settings (e.g., 5/10/15/20 words per session)
  static const int _totalCount = 10;

  /// Prevents duplicate navigation when [_onWordChanged] and [_handleChoice]
  /// both detect an empty word state.
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    widget.wordProvider.addListener(_onWordChanged);
    AppLogger.info('Entering learning page: ${widget.word.originalWord}');
  }

  @override
  void dispose() {
    widget.wordProvider.removeListener(_onWordChanged);
    super.dispose();
  }

  void _onWordChanged() {
    if (!mounted || _isNavigating) return;
    if (widget.wordProvider.currentWord == null) {
      _navigateToSummarizeOnNull();
      return;
    }
    setState(() {});
  }

  /// Navigates to the summary page when [WordProvider.currentWord] becomes
  /// null, using [WordProvider.setFallbackWord] to satisfy the required
  /// [LearningSummarizePage.wordsUnknown] parameter.
  void _navigateToSummarizeOnNull() {
    _isNavigating = true;
    widget.wordProvider.setFallbackWord();
    final word = widget.wordProvider.currentWord!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LearningSummarizePage(
            wordsUnknown: word,
            wordsLearned: _learnedCount,
            wordsReviewed: 0,
            wordsToReview: 0,
            wordProvider: widget.wordProvider,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = widget.wordProvider.currentWord;

    // _onWordChanged has already scheduled navigation for the null case
    // via post-frame callback; show a blank scaffold while the frame
    // completes.
    if (currentWord == null) {
      return const Scaffold();
    }

    return PopScope<Word>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Word? result) {
        if (didPop) return;
        if (!mounted) return;

        // Pop immediately to avoid issues caused by delayed navigation.
        Navigator.pop(context, widget.wordProvider.currentWord);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.learningTitle)),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: _learnedCount / _totalCount,
                        ),
                        builder: (context, value, child) {
                          return LinearProgressIndicatorM3E(
                            value: value,
                            trackColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_learnedCount/$_totalCount',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
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
                  word: currentWord,
                  onUpdated: (updated) {
                    widget.wordProvider.updateWord(updated);
                  },
                  maskTranslation: true,
                ),
              ),
              // Keep content above and reserve the bottom third for actions.
              Spacer(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      onPressed: () => _handleChoice(fsrs.Rating.easy),
                      child: Text(context.l10n.ratingEasy),
                    ),
                    FilledButton(
                      onPressed: () => _handleChoice(fsrs.Rating.good),
                      child: Text(context.l10n.ratingGood),
                    ),
                    FilledButton(
                      onPressed: () => _handleChoice(fsrs.Rating.hard),
                      child: Text(context.l10n.ratingHard),
                    ),
                    FilledButton(
                      onPressed: () => _handleChoice(fsrs.Rating.again),
                      child: Text(context.l10n.ratingAgain),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles user rating and loads the next word.
  Future<void> _handleChoice(fsrs.Rating rating) async {
    final currentWord = widget.wordProvider.currentWord;
    AppLogger.info('Learning Select: $rating - ${currentWord?.originalWord}');

    if (currentWord != null) {
      await widget.wordProvider.reviewWord(currentWord, rating);
    }

    await widget.wordProvider.nextReviewWord();
    final nextWord = widget.wordProvider.currentWord;

    late int nextLearnedCount;
    if (_learnedCount < _totalCount) {
      nextLearnedCount = _learnedCount + 1;
    } else {
      nextLearnedCount = _learnedCount;
    }

    if (nextWord == null) {
      AppLogger.info('No more words to review, finishing session');
      // _onWordChanged already scheduled navigation via
      // _navigateToSummarizeOnNull when currentWord became null.
      return;
    }

    if (!mounted) return;

    if (nextLearnedCount >= _totalCount) {
      _isNavigating = true;
      // TODO: Track actual wordsReviewed and wordsToReview counts (see above)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LearningSummarizePage(
            wordsUnknown: nextWord,
            wordsLearned: nextLearnedCount,
            wordsReviewed: 0,
            wordsToReview: 0,
            wordProvider: widget.wordProvider,
          ),
        ),
      );
      return;
    }

    setState(() {
      _learnedCount = nextLearnedCount;
    });
  }
}
