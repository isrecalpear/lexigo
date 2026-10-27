/// Study page that displays words for preview and learning initiation.
///
/// Shows the current word on a hero card, lets the user shuffle to another
/// random word and starts the interactive learning session.
library;

// Dart imports:
import 'dart:math' as math;

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
import 'package:lexigo/utils/app_logger.dart';

/// Widget that displays a single word and allows starting learning.
class StartPage extends StatefulWidget {
  /// Creates the study landing page.
  const StartPage({
    super.key,
    required this.learningLanguage,
    required this.wordProvider,
  });

  /// The currently selected learning language.
  final LanguageCode learningLanguage;

  /// Centralized word state shared across the learning flow.
  final WordProvider wordProvider;

  @override
  State<StartPage> createState() => _StartPageState();
}

/// State for StartPage that manages word loading and navigation.
class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing start page');
    widget.wordProvider.addListener(_onWordChanged);
  }

  @override
  void dispose() {
    widget.wordProvider.removeListener(_onWordChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Word? displayWord = widget.wordProvider.currentWord;
    if (displayWord == null) {
      // [WordProvider] starts with the language fallback word and keeps it on
      // screen when the library is empty, so this is only reached while the
      // learning page is on top and temporarily reports "no next word".
      return const Scaffold();
    }
    final bool wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: wide
            ? _buildWideLayout(context, displayWord)
            : _buildCompactLayout(context, displayWord),
      ),
    );
  }

  /// Stacked layout used on phones and narrow windows.
  Widget _buildCompactLayout(BuildContext context, Word displayWord) {
    return AppContent(
      maxWidth: 720,
      child: Column(
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                const EdgeInsets padding = EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xs,
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
                      children: _buildStudyContent(context, displayWord),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  /// Two-column layout used on wide desktop windows.
  Widget _buildWideLayout(BuildContext context, Word displayWord) {
    return AppContent(
      maxWidth: 1040,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(flex: 3, child: _buildWordCard(context, displayWord)),
              const SizedBox(width: AppSpacing.huge),
              SizedBox(
                width: 290,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppEyebrow(
                      context.l10n.sectionStudy,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.startPrompt,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(height: 1.25),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SwipeHint(),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _startLearning,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(context.l10n.startLearning),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.shuffle_rounded),
                        label: Text(context.l10n.next),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Prompt, word card and swipe hint used by the compact layout.
  List<Widget> _buildStudyContent(BuildContext context, Word displayWord) {
    return <Widget>[
      AppEyebrow(context.l10n.sectionStudy, icon: Icons.auto_awesome_rounded),
      const SizedBox(height: AppSpacing.xs),
      Text(
        context.l10n.startPrompt,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(height: 1.25),
      ),
      const SizedBox(height: AppSpacing.xl),
      _buildWordCard(context, displayWord),
      const SizedBox(height: AppSpacing.sm),
      _SwipeHint(),
    ];
  }

  /// Hero word card with the horizontal swipe shortcut.
  Widget _buildWordCard(BuildContext context, Word displayWord) {
    return GestureDetector(
      onHorizontalDragEnd: _onSwipeWordCard,
      child: Hero(
        tag: widget.wordProvider.heroTag,
        child: WordCard(
          word: displayWord,
          onUpdated: (Word updated) {
            widget.wordProvider.updateWord(updated);
          },
        ),
      ),
    );
  }

  /// Primary actions pinned to the bottom of the study tab.
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.shuffle_rounded),
              label: Text(context.l10n.next),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: FilledButton.icon(
              onPressed: _startLearning,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(context.l10n.startLearning),
            ),
          ),
        ],
      ),
    );
  }

  /// Starts the interactive learning session with a random word.
  ///
  /// The provider keeps showing the fallback word when the current language has
  /// no words, in which case there is nothing to study: the tap is ignored
  /// without changing the page (no blank frame, no flicker).
  Future<void> _startLearning() async {
    final Word? word = await widget.wordProvider.loadRandomWord();
    if (!mounted) return;
    if (word == null) {
      AppLogger.info('Start learning skipped: no words for current language');
      return;
    }
    AppLogger.info('Start learning word: ${word.originalWord}');
    Navigator.of(context)
        .push<Word?>(
          AppRoutes.learning(
            word: word,
            languageCode: widget.learningLanguage,
            wordProvider: widget.wordProvider,
          ),
        )
        .then((Word? returned) {
          if (returned != null) {
            widget.wordProvider.updateWord(returned);
          }
        });
  }

  Future<void> _onSwipeWordCard(DragEndDetails details) async {
    if (details.velocity.pixelsPerSecond.dx < 0) {
      _next();
    }
  }

  /// Loads the next random word via the provider.
  ///
  /// When the library is empty the provider keeps the fallback word, so this
  /// results in no visual change at all.
  void _next() {
    widget.wordProvider.loadRandomWord();
  }

  void _onWordChanged() {
    if (!mounted) return;
    setState(() {});
  }
}

/// Subtle gesture hint shown below the word card.
class _SwipeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.swipe_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            context.l10n.swipeHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
