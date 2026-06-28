library;

import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart';

@TableIndex(name: "idx_word_due", columns: {#cardDueTime})
class WordTable extends Table {
  late final id = integer().autoIncrement()();
  late final languageCode = text()();

  late final originalWord = text()();
  late final originalTranslation = text()();
  late final exampleSentence = text()();
  late final exampleTranslation = text()();

  late final unitId = text().clientDefault(() => "DefaultUnit")();
  late final bookId = text().clientDefault(() => "DefaultBook")();

  late final cardId = integer()();
  late final cardState = integer()();
  late final cardStep = integer()();
  late final cardStability = real().nullable()();
  late final cardDifficulty = real().nullable()();
  late final cardDueTime = dateTime()();
  late final cardLastReviewTime = dateTime().nullable()();

  late final createdAtTime = dateTime()();
  late final updatedAtTime = dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {originalWord, unitId, bookId, cardId},
  ];
}

class WordLearningHistoryTable extends Table {
  late final id = integer().autoIncrement()();
  late final cardId = integer()();
  late final rating = intEnum<Rating>()();
  late final reviewDateTime = dateTime()();
  late final reviewDuration = integer().nullable()();
}
