/// Interactive learning page where users rate their knowledge of words.
///
/// Displays words one at a time with four rating options (Again, Hard, Good,
/// Easy). The translation stays hidden until the user reveals it, which turns
/// the card into a recall prompt. Ratings update the FSRS schedule and load the
/// next word.
library;

// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/app_router.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/records/records_format.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/theme/app_theme.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

/// Interactive learning widget for studying individual words.
class LearningPage extends StatefulWidget {
  /// Creates the learning session page.
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
  bool _obscured = true;

  /// TODO: Make session length configurable in settings (e.g., 5/10/15/20 words per session)
  static const int _totalCount = 10;

  DateTime _reviewStartTime = DateTime.now();

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
    setState(() {
      _reviewStartTime = DateTime.now();
      _obscured = true;
    });
  }

  /// Navigates to the summary page when [WordProvider.currentWord] becomes
  /// null, using [WordProvider.setFallbackWord] to satisfy the required
  /// [LearningSummarizePage.wordsUnknown] parameter.
  void _navigateToSummarizeOnNull() {
    _isNavigating = true;
    widget.wordProvider.setFallbackWord();
    final Word? word = widget.wordProvider.currentWord;
    if (word == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pushSummary(word);
    });
  }

  /// Replaces this page with the summary page, showing [word] as the next one.
  void _pushSummary(Word word) {
    Navigator.of(context).pushReplacement(
      AppRoutes.learningSummary(
        wordsUnknown: word,
        wordsLearned: _learnedCount,
        wordsReviewed: 0,
        wordsToReview: 0,
        wordProvider: widget.wordProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Word? currentWord = widget.wordProvider.currentWord;

    // _onWordChanged has already scheduled navigation for the null case
    // via post-frame callback; show a blank scaffold while the frame
    // completes.
    if (currentWord == null) {
      return const Scaffold();
    }

    return PopScope<Word>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Word? result) async {
        if (didPop || _isNavigating) return;
        _isNavigating = true;

        await widget.wordProvider.nextReviewWord();
        if (!mounted) return;
        if (widget.wordProvider.currentWord == null) {
          widget.wordProvider.setFallbackWord();
        }
        _pushSummary(widget.wordProvider.currentWord!);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.learningTitle),
          centerTitle: false,
        ),
        body: SafeArea(
          top: false,
          child: AppContent(
            maxWidth: 720,
            child: Column(
              children: <Widget>[
                _buildProgress(context),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          const EdgeInsets padding = EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          );
                          return SingleChildScrollView(
                            padding: padding,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: math.max(
                                  0,
                                  constraints.maxHeight - padding.vertical,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Hero(
                                    tag: widget.wordProvider.heroTag,
                                    flightShuttleBuilder:
                                        (
                                          BuildContext flightContext,
                                          Animation<double> animation,
                                          HeroFlightDirection direction,
                                          BuildContext fromContext,
                                          BuildContext toContext,
                                        ) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: toContext.widget,
                                          );
                                        },
                                    child: WordCard(
                                      word: currentWord,
                                      obscured: _obscured,
                                      onToggleObscured: () {
                                        setState(() {
                                          _obscured = !_obscured;
                                        });
                                      },
                                      onUpdated: (Word updated) {
                                        widget.wordProvider.updateWord(updated);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
                ),
                _buildRatingPanel(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Session progress indicator shown under the app bar.
  Widget _buildProgress(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                curve: AppMotion.curve,
                tween: Tween<double>(
                  begin: 0,
                  end: _learnedCount / _totalCount,
                ),
                builder: (BuildContext context, double value, Widget? child) {
                  return LinearProgressIndicatorM3E(
                    value: value,
                    trackColor: theme.colorScheme.surfaceContainerHighest,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$_learnedCount/$_totalCount',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Rating prompt and the four FSRS rating actions.
  Widget _buildRatingPanel(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const List<fsrs.Rating> ratings = <fsrs.Rating>[
      fsrs.Rating.again,
      fsrs.Rating.hard,
      fsrs.Rating.good,
      fsrs.Rating.easy,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.l10n.ratingPrompt,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              for (final fsrs.Rating rating in ratings)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    child: _RatingAction(
                      rating: rating,
                      onPressed: () => _handleChoice(rating),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handles user rating and loads the next word.
  Future<void> _handleChoice(fsrs.Rating rating) async {
    final Word? currentWord = widget.wordProvider.currentWord;
    AppLogger.info('Learning Select: $rating - ${currentWord?.originalWord}');
    final int reviewDuration = DateTime.now()
        .difference(_reviewStartTime)
        .inMilliseconds;
    if (currentWord != null) {
      await widget.wordProvider.reviewWord(currentWord, rating, reviewDuration);
    }

    await widget.wordProvider.nextReviewWord();
    final Word? nextWord = widget.wordProvider.currentWord;

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
        AppRoutes.learningSummary(
          wordsUnknown: nextWord,
          wordsLearned: nextLearnedCount,
          wordsReviewed: 0,
          wordsToReview: 0,
          wordProvider: widget.wordProvider,
        ),
      );
      return;
    }

    setState(() {
      _learnedCount = nextLearnedCount;
      _obscured = true;
    });
  }
}

/// Colored rating button used by the learning session.
class _RatingAction extends StatelessWidget {
  const _RatingAction({required this.rating, required this.onPressed});

  final fsrs.Rating rating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background = ratingContainerColor(colors, rating);
    final Color foreground = ratingOnColor(colors, rating);
    final String label = ratingLabel(context.l10n, rating);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxs,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(ratingIcon(rating), color: foreground, size: 20),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
