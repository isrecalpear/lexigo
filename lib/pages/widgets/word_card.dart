// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/datas/word.dart';
import 'package:lexigo/datas/word_provider.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    this.onUpdated,
  });
  final Word word;
  final ValueChanged<Word>? onUpdated;

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
                      word.originalWord,
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
                          signAsWrong(context);
                        } else if (value == '熟知') {
                          signAsKnown();
                        }
                      },
                      itemBuilder: (context) => [
                        // TODO: Change to Enum
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
                  word.translation,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Text(
                  word.originalExample,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  word.exampleTranslation,
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

  void signAsKnown() {
    debugPrint('WordCard: 标记为熟知 for ${word.originalWord}');
  }

  Future<void> signAsWrong(BuildContext context) async {
    final updated = await WordProvider().signAsWrong(context, word);
    if (updated != null) {
      onUpdated?.call(updated);
    }
  }
}
