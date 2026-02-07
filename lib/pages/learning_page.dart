import 'package:flutter/material.dart';
import 'package:lexigo/pages/widgets/word_card.dart';
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/word_provider.dart';
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
    AppLogger.info('进入学习页面: ${widget.word.originalWord}');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope<Word>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Word? result) {
        if (didPop) return;
        if (!mounted) return;
        
        // 立即弹出，避免延迟导致的问题
        Navigator.pop(context, _currentWord);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('学习')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: _heroTag,
                  flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
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
                      : WordCard.fromWord(_currentWord!),
                ),
                const SizedBox(height: 12),
                // 上方内容占据上方空间，按钮区域占据底部三分之一
                Expanded(child: SizedBox()),
                Container(
                  height: screenHeight / 3,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          onPressed: () => _handleChoice('认识'),
                          child: const Text('认识'),
                        ),
                        FilledButton(
                          onPressed: () => _handleChoice('模糊'),
                          child: const Text('模糊'),
                        ),
                        FilledButton(
                          onPressed: () => _handleChoice('忘记'),
                          child: const Text('忘记'),
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

  Future<void> _handleChoice(String choice) async {
    AppLogger.info('学习选择: $choice - ${_currentWord?.originalWord}');
    debugPrint('学习选择: $choice - ${_currentWord?.originalWord}');
    final nextWord = await _wordProvider.getWord();
    if (!mounted) return;
    setState(() {
      _currentWord = nextWord;
      _heroTag = 'word_${_currentWord!.originalWord}';
    });
  }
}
