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

class LearningPage extends StatefulWidget {
  const LearningPage({super.key, required this.word, required this.heroTag});

  final Word word;
  final String heroTag;

  @override
  State<LearningPage> createState() => _LearningPageState();
}

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
    final screenHeight = MediaQuery.of(context).size.height;

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
                const SizedBox(height: 12),
                // Keep content above and reserve the bottom third for actions.
                Expanded(child: SizedBox()),
                Container(
                  height: screenHeight / 3,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChoice(fsrs.Rating rating) async {
    AppLogger.info('Learning Select: $rating - ${_currentWord?.originalWord}');
    _wordProvider.reviewWord(_currentWord!, rating);
    final nextWord = await _wordProvider.getWord();
    
    if (!mounted) return;
    setState(() {
      _currentWord = nextWord;
      _heroTag = 'word_${_currentWord!.originalWord}';
    });
  }
}
