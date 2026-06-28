/// Study page that displays words for preview and learning initiation.
///
/// Shows the current word with "Next" button to browse and a "Start" button
/// to begin the interactive learning session for the selected language.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/learning/learn.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/backend/word/global_provider.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Widget that displays a single word and allows starting learning.
class StartPage extends StatefulWidget {
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
    if (widget.wordProvider.currentWord == null) {
      widget.wordProvider.setFallbackWord();
    }
    Word displayWord = widget.wordProvider.currentWord!;

    return Scaffold(
      body: SafeArea(
        left: false,
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    context.l10n.startPrompt,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onHorizontalDragEnd: _onSwipeWordCard,
                      child: Hero(
                        tag: widget.wordProvider.heroTag,
                        child: WordCard(
                          word: displayWord,
                          onUpdated: (updated) {
                            widget.wordProvider.updateWord(updated);
                          },
                        ),
                      ),
                    );
                  },
                ),
                FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: Text(context.l10n.next),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(context.l10n.startLearning),
        icon: const Icon(Icons.play_arrow),
        onPressed: _startLearning,
      ),
    );
  }

  /// Starts the interactive learning session with a random word.
  Future<void> _startLearning() async {
    await widget.wordProvider.loadRandomWord();
    final word = widget.wordProvider.currentWord;
    if (word == null) return;
    if (!mounted) return;
    AppLogger.info('Start learning word: ${word.originalWord}');
    Navigator.of(context)
        .push<Word?>(
          MaterialPageRoute(
            builder: (context) => LearningPage(
              word: word,
              learningLanguage: widget.learningLanguage,
              wordProvider: widget.wordProvider,
            ),
          ),
        )
        .then((returned) {
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
  void _next() {
    widget.wordProvider.loadRandomWord();
  }

  void _onWordChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
