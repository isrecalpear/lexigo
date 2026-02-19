/// Study page that displays words for preview and learning initiation.
///
/// Shows the current word with "Next" button to browse and a "Start" button
/// to begin the interactive learning session for the selected language.

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/orm/word_repository.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/learning/learn.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/utils/app_logger.dart';

/// Widget that displays a single word and allows starting learning.
class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.learningLanguage});

  final LanguageCode learningLanguage;

  @override
  State<StartPage> createState() => _StartPageState();
}

/// State for StartPage that manages word loading and navigation.
class _StartPageState extends State<StartPage> {
  Word? _currentWord;
  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (_currentWord == null) {
                      return const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final tag = 'word_${_currentWord!.originalWord}';
                    return Hero(
                      tag: tag,
                      child: WordCard(
                        word: _currentWord!,
                        onUpdated: (updated) {
                          setState(() {
                            _currentWord = updated;
                          });
                        },
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

  /// Handles next button press.
  void _next() {
    _loadNextWord();
  }

  /// Starts the interactive learning session.
  void _startLearning() {
    if (_currentWord == null) return;
    final word = _currentWord!;
    AppLogger.info('Start learning word: ${word.originalWord}');
    final tag = 'word_${word.originalWord}';
    Navigator.of(context)
        .push<Word?>(
          MaterialPageRoute(
            builder: (context) => LearningPage(
              word: word,
              heroTag: tag,
              learningLanguage: widget.learningLanguage,
            ),
          ),
        )
        .then((returned) {
          if (returned != null) {
            setState(() {
              _currentWord = returned;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    AppLogger.info('Initializing start page');
    _loadNextWord();
  }

  @override
  void didUpdateWidget(covariant StartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.learningLanguage != widget.learningLanguage) {
      setState(() {
        _currentWord = null;
      });
      _loadNextWord();
    }
  }

  /// Loads the next word from the database for the current language.
  Future<void> _loadNextWord() async {
    final repo = await WordRepository.open();
    final word = await repo.getRandomWord(widget.learningLanguage);
    if (!mounted) return;
    setState(() {
      _currentWord = word;
    });
  }
}
