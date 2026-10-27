/// Interactive learning page where users rate their knowledge of words.
///
/// Displays words one at a time with four rating options (Again, Hard, Good,
/// Easy). The translation stays hidden until the user reveals it, which turns
/// the card into a recall prompt.
///
/// Revealing the answer means the word was not recalled: it is automatically
/// rated as "Again" and the rating panel collapses to a single "Next" action,
/// so no other rating can be picked afterwards. Tapping "Again" while the card
/// is still obscured does the same — it reveals the answer, records the rating
/// and only offers "Next". The other ratings update the FSRS schedule and load
/// the next word directly.
library;

// Dart imports:
import 'dart:async';
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

  /// Whether the answer has been revealed on the current word.
  ///
  /// Revealing the answer records an automatic [fsrs.Rating.again]; once this
  /// flag is set the card can no longer be obscured and the rating panel shows
  /// only the "Next" action.
  bool _answerRevealed = false;

  /// Disables the actions while a review is being written or the next word is
  /// being loaded, so a double tap cannot rate or advance twice.
  bool _isBusy = false;

  /// Swallows taps for a short moment after a new word appears.
  ///
  /// A fast second tap (for example a double tap on "Next") is otherwise
  /// delivered to the freshly built rating panel and would rate the next word
  /// before the user even sees it.
  bool _ignoreInput = false;

  /// Resets [_ignoreInput] after [_inputCooldown].
  Timer? _inputTimer;

  /// Longer than Flutter's 300 ms double-tap timeout, so even a slow double tap
  /// cannot reach the freshly built rating panel.
  static const Duration _inputCooldown = Duration(milliseconds: 350);

  /// [Card.cardId] of the word currently on screen, used to tell a genuinely
  /// new word apart from an in-place edit of the same word.
  int? _wordCardId;

  /// TODO: Make session length configurable in settings (e.g., 5/10/15/20 words per session)
  static const int _totalCount = 10;

  DateTime _reviewStartTime = DateTime.now();

  /// Prevents duplicate navigation when [_onWordChanged] and [_handleChoice]
  /// both detect an empty word state.
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _wordCardId = widget.wordProvider.currentWord?.card.cardId;
    widget.wordProvider.addListener(_onWordChanged);
    AppLogger.info('Entering learning page: ${widget.word.originalWord}');
  }

  @override
  void dispose() {
    _inputTimer?.cancel();
    widget.wordProvider.removeListener(_onWordChanged);
    super.dispose();
  }

  void _onWordChanged() {
    if (!mounted || _isNavigating) return;
    final Word? currentWord = widget.wordProvider.currentWord;
    if (currentWord == null) {
      _navigateToSummarizeOnNull();
      return;
    }
    final bool wordChanged = currentWord.card.cardId != _wordCardId;
    _wordCardId = currentWord.card.cardId;
    setState(() {
      if (wordChanged) {
        _reviewStartTime = DateTime.now();
        _obscured = true;
        _answerRevealed = false;
        _isBusy = false;
        _ignoreInput = true;
      }
    });
    if (wordChanged) {
      _inputTimer?.cancel();
      _inputTimer = Timer(_inputCooldown, () {
        if (!mounted) return;
        setState(() {
          _ignoreInput = false;
        });
      });
    }
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
                    builder: (BuildContext context, BoxConstraints constraints) {
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
                                  // Once revealed, the answer must stay
                                  // visible: the card is locked to the
                                  // "Next" action only. The card id and the
                                  // short input cooldown after a word change
                                  // keep a stale tap from rating the new
                                  // word by accident.
                                  onToggleObscured: _answerRevealed
                                      ? null
                                      : () => _revealAnswerAndRateAgain(
                                          currentWord.card.cardId,
                                        ),
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
                IgnorePointer(
                  ignoring: _ignoreInput,
                  child: _buildRatingPanel(context),
                ),
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
  ///
  /// Once the answer has been revealed the panel is replaced by
  /// [_buildRevealedPanel], which only offers the "Next" action.
  Widget _buildRatingPanel(BuildContext context) {
    if (_answerRevealed) {
      return _buildRevealedPanel(context);
    }
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
                      onPressed: _isBusy ? null : () => _handleChoice(rating),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Panel shown after the answer was revealed.
  ///
  /// The word has already been rated [fsrs.Rating.again] automatically, so the
  /// "Again" pill is only a status indicator and "Next" is the sole available
  /// action.
  Widget _buildRevealedPanel(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    const fsrs.Rating rating = fsrs.Rating.again;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          AppPill(
            label: ratingLabel(context.l10n, rating),
            icon: ratingIcon(rating),
            color: ratingOnColor(colors, rating),
            backgroundColor: ratingContainerColor(colors, rating),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isBusy ? null : _handleNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(context.l10n.next),
            ),
          ),
        ],
      ),
    );
  }

  /// Reveals the answer of the word with [cardId], records an automatic
  /// [fsrs.Rating.again] and locks the card to the "Next" action.
  ///
  /// [cardId] rejects a callback that was already dispatched against the
  /// previous word; taps delivered after the rebuild are covered by
  /// [_ignoreInput].
  Future<void> _revealAnswerAndRateAgain(int cardId) async {
    final Word? currentWord = widget.wordProvider.currentWord;
    if (_answerRevealed ||
        _isBusy ||
        _ignoreInput ||
        currentWord == null ||
        currentWord.card.cardId != cardId) {
      return;
    }
    final int reviewDuration = DateTime.now()
        .difference(_reviewStartTime)
        .inMilliseconds;
    setState(() {
      _obscured = false;
      _answerRevealed = true;
      _isBusy = true;
    });
    AppLogger.info('Learning Reveal → Again: ${currentWord.originalWord}');
    try {
      await widget.wordProvider.reviewWord(
        currentWord,
        fsrs.Rating.again,
        reviewDuration,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  /// Handles a rating picked while the answer is still hidden.
  ///
  /// "Again" reveals the answer instead of moving on (see
  /// [_revealAnswerAndRateAgain]); the other ratings are recorded and advance
  /// to the next word.
  Future<void> _handleChoice(fsrs.Rating rating) async {
    if (_isBusy || _ignoreInput || _answerRevealed) return;
    final Word? currentWord = widget.wordProvider.currentWord;
    if (currentWord == null) return;
    if (rating == fsrs.Rating.again) {
      await _revealAnswerAndRateAgain(currentWord.card.cardId);
      return;
    }
    AppLogger.info('Learning Select: $rating - ${currentWord.originalWord}');
    final int reviewDuration = DateTime.now()
        .difference(_reviewStartTime)
        .inMilliseconds;
    setState(() {
      _isBusy = true;
    });
    try {
      await widget.wordProvider.reviewWord(currentWord, rating, reviewDuration);
      await _advance();
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  /// Moves past the current word after it was automatically rated "Again".
  Future<void> _handleNext() async {
    if (_isBusy || _ignoreInput || !_answerRevealed) return;
    setState(() {
      _isBusy = true;
    });
    try {
      await _advance();
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  /// Loads the next word and ends the session once enough words were studied.
  Future<void> _advance() async {
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
    });
  }
}

/// Colored rating button used by the learning session.
class _RatingAction extends StatelessWidget {
  const _RatingAction({required this.rating, required this.onPressed});

  final fsrs.Rating rating;

  /// Tapping is disabled while the previous review is still being written, in
  /// which case [onPressed] is `null`.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color background = ratingContainerColor(colors, rating);
    final Color foreground = ratingOnColor(colors, rating);
    final String label = ratingLabel(context.l10n, rating);
    return Semantics(
      button: true,
      enabled: onPressed != null,
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
