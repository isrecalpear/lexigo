// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/word_provider.dart';
import 'package:lexigo/pages/learning_page.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/utils/app_logger.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final WordProvider _wordProvider = WordProvider();
  Word? _currentWord;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text('你认识吗？', style: TextStyle(fontSize: 24))),
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
                    child: WordCard(word: _currentWord!),
                  );
                },
              ),
              FilledButton(onPressed: _next, child: const Text('下一个')),
              const SizedBox(height: 128),
            ],
          ),
        ],
      ),
      floatingActionButton:FloatingActionButton.extended(
        onPressed: _startLearning,
        label: const Text('开始学习'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  void _next() {
    _loadNextWord();
  }

  void _startLearning() {
    if (_currentWord == null) return;
    final word = _currentWord!;
    AppLogger.info('开始学习单词: ${word.originalWord}');
    final tag = 'word_${word.originalWord}';
    Navigator.of(context)
        .push<Word?>(
      MaterialPageRoute(
        builder: (context) => LearningPage(word: word, heroTag: tag),
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
    AppLogger.info('开始页面初始化');
    _loadNextWord();
  }

  Future<void> _loadNextWord() async {
    final word = await _wordProvider.getWord();
    if (!mounted) return;
    setState(() {
      _currentWord = word;
    });
  }
}
