import 'package:flutter/material.dart';
import 'package:lexigo/datas/word.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.originalWord,
    required this.translation,
    required this.originalExample,
    required this.exampleTranslation,
  });
  final String originalWord;
  final String translation;
  final String originalExample;
  final String exampleTranslation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 140),
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          shadowColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      originalWord,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == '纠错') {
                          signAsWrong();
                        } else if (value == '熟知') {
                          signAsKnown();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: '纠错', child: Text('纠错')),
                        const PopupMenuItem(value: '熟知', child: Text('标记为熟知')),
                      ],
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  translation,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Text(
                  originalExample,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  exampleTranslation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  factory WordCard.fromWord(Word word) {
    return WordCard(
      originalWord: word.originalWord,
      translation: word.translation,
      originalExample: word.originalExample,
      exampleTranslation: word.exampleTranslation,
    );
  }

  void signAsKnown() {
    debugPrint('WordCard: 标记为熟知 for $originalWord');
  }

  void signAsWrong() {
    debugPrint('WordCard: 纠错 for $originalWord');
  }
}
