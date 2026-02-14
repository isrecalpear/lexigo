/// Interactive learning page where users rate their knowledge of words.
///
/// Displays words one at a time with four rating options (Again, Hard, Good, Easy).
/// Updates FSRS scheduling based on ratings and loads the next word.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/word_provider.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Interactive learning widget for studying individual words.
class LearningPage extends StatefulWidget {
  const LearningPage({
    super.key,
    required this.word,
    required this.heroTag,
    required this.learningLanguage,
  });

  /// The word being studied.
  final Word word;

  /// Hero animation tag for word card transition.
  final String heroTag;

  /// The currently selected learning language.
  final LanguageCode learningLanguage;

  @override
  State<LearningPage> createState() => _LearningPageState();
}

/// State for LearningPage that manages word progression and scheduling.
class _LearningPageState extends State<LearningPage> {
  final WordProvider _wordProvider = WordProvider();
  late String _heroTag;
  Word? _currentWord;

  @override
  void initState() {
    super.initState();
    _currentWord = widget.word;
    _heroTag = widget.heroTag;
    AppLogger.info('Entering learning page: ${widget.word.originalWord}');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Word>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Word? result) {
        if (didPop) return;
        if (!mounted) return;

        // Pop immediately to avoid issues caused by delayed navigation.
        Navigator.pop(context, _currentWord);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.learningTitle)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: _heroTag,
                  flightShuttleBuilder:
                      (context, animation, direction, fromContext, toContext) {
                        return Material(
                          color: Colors.transparent,
                          child: toContext.widget,
                        );
                      },
                  child: _currentWord == null
                      ? const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : WordCard(
                          word: _currentWord!,
                          onUpdated: (updated) {
                            setState(() {
                              _currentWord = updated;
                              _heroTag = 'word_${updated.originalWord}';
                            });
                          },
                        ),
                ),
                // Keep content above and reserve the bottom third for actions.
                Expanded(child: SizedBox()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handles user rating and loads the next word.
  Future<void> _handleChoice(fsrs.Rating rating) async {
    AppLogger.info('Learning Select: $rating - ${_currentWord?.originalWord}');
    _wordProvider.reviewWord(_currentWord!, rating);
    final nextWord = await _wordProvider.getWord(
      language: widget.learningLanguage,
    );

    if (mounted) {
      setState(() {
        _currentWord = nextWord;
        _heroTag = 'word_${_currentWord!.originalWord}';
      });
    }
  }
}
