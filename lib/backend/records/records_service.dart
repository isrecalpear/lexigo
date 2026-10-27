/// Read-only queries and models backing the records page.
///
/// The page needs three kinds of data: what happened on a given day, what is
/// scheduled for upcoming days, and long running statistics. All of it is
/// derived from `word_table` (FSRS state) and `word_learning_history_table`
/// (review log); nothing here writes to the database.
library;

// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart';

// Project imports:
import 'package:lexigo/backend/database/interface.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/backend/word/manager.dart';

/// A single review event that happened on a day.
class ReviewEntry {
  const ReviewEntry({
    required this.cardId,
    required this.word,
    required this.translation,
    required this.rating,
    required this.reviewedAt,
    required this.durationMs,
    required this.state,
    required this.stability,
    required this.difficulty,
  });

  /// FSRS card id, used to open the word detail sheet.
  final int cardId;

  final String word;
  final String translation;
  final Rating rating;

  /// Local time of the review.
  final DateTime reviewedAt;

  /// Time spent on the review, in milliseconds, when recorded.
  final int? durationMs;

  /// Card state *after* the review (FSRS `State.value`).
  final int state;

  final double? stability;
  final double? difficulty;

  /// Whether the user forgot the word (rated "Again").
  bool get isForgotten => rating == Rating.again;
}

/// A word scheduled on an upcoming day.
class DueEntry {
  const DueEntry({
    required this.cardId,
    required this.word,
    required this.translation,
    required this.due,
    required this.state,
    required this.stability,
    required this.difficulty,
  });

  final int cardId;
  final String word;
  final String translation;

  /// Local due time.
  final DateTime due;
  final int state;
  final double? stability;
  final double? difficulty;
}

/// Aggregated numbers for one cell of the week strip.
class DayOverview {
  const DayOverview({
    required this.date,
    required this.reviewedCount,
    required this.forgottenCount,
    required this.dueCount,
    required this.isFuture,
  });

  final DateTime date;
  final int reviewedCount;
  final int forgottenCount;

  /// Number of studied cards whose next review lands on [date]. Only meaningful
  /// for future days.
  final int dueCount;
  final bool isFuture;
}

/// Data for the week strip.
class WeekOverview {
  const WeekOverview({
    required this.weekStart,
    required this.days,
    required this.newWordsRemaining,
  });

  final DateTime weekStart;
  final List<DayOverview> days;

  /// Words that have never been reviewed (available to learn any day).
  final int newWordsRemaining;
}

/// Everything needed to render one selected day.
class DayReport {
  const DayReport({
    required this.date,
    required this.isFuture,
    required this.reviews,
    required this.dueWords,
    required this.dueCount,
    required this.overdueCount,
    required this.newWordsRemaining,
  });

  final DateTime date;
  final bool isFuture;

  /// Review events for past days and today.
  final List<ReviewEntry> reviews;

  /// Words scheduled on this day; capped for display.
  final List<DueEntry> dueWords;

  final int dueCount;
  final int overdueCount;
  final int newWordsRemaining;

  bool get isEmpty => isFuture ? dueCount == 0 : reviews.isEmpty;
}

/// Long-running learning statistics.
class LearningStats {
  const LearningStats({
    required this.streakDays,
    required this.last7DayCounts,
    required this.last7DayReviews,
    required this.retention,
    required this.masteredWords,
    required this.vocabularySize,
    required this.totalReviews,
  });

  final int streakDays;

  /// Review counts for the last seven days, oldest first (index 6 = today).
  final List<int> last7DayCounts;
  final int last7DayReviews;

  /// Share of reviews that were not rated "Again" over the last seven days.
  final double? retention;

  final int masteredWords;
  final int vocabularySize;
  final int totalReviews;
}

/// One entry of a single card's review history.
class CardReview {
  const CardReview({
    required this.rating,
    required this.reviewedAt,
    required this.durationMs,
  });

  final Rating rating;
  final DateTime reviewedAt;
  final int? durationMs;
}

/// A word plus its review history and FSRS state.
class CardInsight {
  const CardInsight({required this.word, required this.history});

  final Word word;
  final List<CardReview> history;
}

/// Queries and helpers used by the records page.
class RecordsService {
  RecordsService({Database? database, WordManager? wordManager})
    : _database = database ?? Database(),
      _wordManager = wordManager ?? WordManager();

  final Database _database;
  final WordManager _wordManager;

  /// Display cap for the "scheduled words" list of a future day.
  static const int _dueListLimit = 100;

  // Date helpers -------------------------------------------------------------

  static DateTime dayStart(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime nextDay(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  /// Monday of the week containing [day].
  static DateTime weekStartOf(DateTime day) =>
      dayStart(DateTime(day.year, day.month, day.day - (day.weekday - 1)));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// FSRS-5 retrievability after [elapsedDays], i.e. the probability that the
  /// word is still remembered. `R(t, S) = (1 + 19/81 * t / S)^(-0.5)`.
  static double retrievability(double stability, double elapsedDays) {
    if (stability <= 0) {
      return 0;
    }
    const double factor = 19 / 81;
    final double t = math.max(0, elapsedDays);
    return math
        .pow(1 + factor * t / stability, -0.5)
        .toDouble()
        .clamp(0.0, 1.0)
        .toDouble();
  }

  /// Retrievability as of [at] for a card last reviewed at [lastReview].
  static double? retrievabilityAt({
    required double? stability,
    required DateTime? lastReview,
    DateTime? at,
  }) {
    if (stability == null || lastReview == null) {
      return null;
    }
    final double elapsedDays =
        (at ?? DateTime.now()).difference(lastReview).inMinutes.toDouble() /
        (60 * 24);
    return retrievability(stability, elapsedDays);
  }

  // Queries ------------------------------------------------------------------

  /// Loads the week strip for the week starting at [weekStart] (Monday).
  Future<WeekOverview> loadWeek(
    LanguageCode language,
    DateTime weekStart,
  ) async {
    final DateTime start = dayStart(weekStart);
    final List<DateTime> days = List<DateTime>.generate(
      7,
      (int index) => DateTime(start.year, start.month, start.day + index),
    );
    final DateTime end = nextDay(days.last);

    final Map<DateTime, int> reviewed = <DateTime, int>{};
    final Map<DateTime, int> forgotten = <DateTime, int>{};
    for (final ReviewEntry entry in await _historyInRange(
      language,
      start,
      end,
    )) {
      final DateTime day = dayStart(entry.reviewedAt);
      reviewed[day] = (reviewed[day] ?? 0) + 1;
      if (entry.isForgotten) {
        forgotten[day] = (forgotten[day] ?? 0) + 1;
      }
    }

    final Map<DateTime, int> dueByDay = await _dueCountsByDay(
      language,
      start,
      end,
    );
    final int newWords = await _countWords(
      language,
      _database.wordTable.cardLastReviewTime.isNull(),
    );
    final DateTime today = dayStart(DateTime.now());

    return WeekOverview(
      weekStart: start,
      days: <DayOverview>[
        for (final DateTime day in days)
          DayOverview(
            date: day,
            reviewedCount: reviewed[dayStart(day)] ?? 0,
            forgottenCount: forgotten[dayStart(day)] ?? 0,
            dueCount: dueByDay[dayStart(day)] ?? 0,
            isFuture: day.isAfter(today),
          ),
      ],
      newWordsRemaining: newWords,
    );
  }

  /// Loads the content of [date].
  ///
  /// Past days and today return the review log; future days return a forecast
  /// (due words, backlog and remaining new words).
  Future<DayReport> loadDay(LanguageCode language, DateTime date) async {
    final DateTime day = dayStart(date);
    final DateTime today = dayStart(DateTime.now());
    final bool isFuture = day.isAfter(today);

    if (isFuture) {
      final List<DueEntry> dueWords = await _dueWordsOnDay(language, day);
      final int dueCount = await _countWords(
        language,
        Expression.and(<Expression<bool>>[
          _database.wordTable.cardLastReviewTime.isNotNull(),
          _database.wordTable.cardDueTime.isBiggerOrEqualValue(day.toUtc()),
          _database.wordTable.cardDueTime.isSmallerThanValue(
            nextDay(day).toUtc(),
          ),
        ]),
      );
      final int overdue = await _countWords(
        language,
        Expression.and(<Expression<bool>>[
          _database.wordTable.cardLastReviewTime.isNotNull(),
          _database.wordTable.cardDueTime.isSmallerThanValue(day.toUtc()),
        ]),
      );
      final int newWords = await _countWords(
        language,
        _database.wordTable.cardLastReviewTime.isNull(),
      );
      return DayReport(
        date: day,
        isFuture: true,
        reviews: const <ReviewEntry>[],
        dueWords: dueWords,
        dueCount: dueCount,
        overdueCount: overdue,
        newWordsRemaining: newWords,
      );
    }

    return DayReport(
      date: day,
      isFuture: false,
      reviews: await _historyInRange(language, day, nextDay(day)),
      dueWords: const <DueEntry>[],
      dueCount: 0,
      overdueCount: 0,
      newWordsRemaining: 0,
    );
  }

  /// Loads learning statistics for [language].
  Future<LearningStats> loadStats(LanguageCode language) async {
    final DateTime today = dayStart(DateTime.now());
    final DateTime from = DateTime(today.year, today.month, today.day - 6);
    final List<ReviewEntry> weekHistory = await _historyInRange(
      language,
      from,
      nextDay(today),
    );

    final List<int> counts = List<int>.filled(7, 0);
    int remembered = 0;
    for (final ReviewEntry entry in weekHistory) {
      final int index = dayStart(entry.reviewedAt).difference(from).inDays;
      if (index >= 0 && index < 7) {
        counts[index] += 1;
      }
      if (!entry.isForgotten) {
        remembered += 1;
      }
    }
    final int total = weekHistory.length;

    return LearningStats(
      streakDays: await _streakDays(language),
      last7DayCounts: counts,
      last7DayReviews: total,
      retention: total == 0 ? null : remembered / total,
      masteredWords: await _countWords(
        language,
        _database.wordTable.cardState.equals(State.review.value),
      ),
      vocabularySize: await _countWords(language, null),
      totalReviews: await _totalReviews(language),
    );
  }

  /// Loads the word and review history of a single card.
  Future<CardInsight?> loadCardInsight(int cardId) async {
    final Word? word = await _wordManager.getWordByCardId(cardId);
    if (word == null) {
      return null;
    }
    final rows =
        await (_database.select(_database.wordLearningHistoryTable)
              ..where((t) => t.cardId.equals(cardId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.reviewDateTime,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    return CardInsight(
      word: word,
      history: <CardReview>[
        for (final row in rows)
          CardReview(
            rating: row.rating,
            reviewedAt: row.reviewDateTime.toLocal(),
            durationMs: row.reviewDuration,
          ),
      ],
    );
  }

  // Internals ----------------------------------------------------------------

  /// Review events in `[from, to)` for [language], mapped to local time.
  Future<List<ReviewEntry>> _historyInRange(
    LanguageCode language,
    DateTime from,
    DateTime to,
  ) async {
    final history = _database.wordLearningHistoryTable;
    final word = _database.wordTable;
    final query =
        _database.select(history).join(<Join>[
            innerJoin(word, word.cardId.equalsExp(history.cardId)),
          ])
          ..where(
            Expression.and(<Expression<bool>>[
              word.languageCode.equals(language.name),
              history.reviewDateTime.isBiggerOrEqualValue(from.toUtc()),
              history.reviewDateTime.isSmallerThanValue(to.toUtc()),
            ]),
          )
          ..orderBy([OrderingTerm(expression: history.reviewDateTime)]);
    final rows = await query.get();
    return <ReviewEntry>[
      for (final row in rows)
        ReviewEntry(
          cardId: row.readTable(history).cardId,
          word: row.readTable(word).originalWord,
          translation: row.readTable(word).originalTranslation,
          rating: row.readTable(history).rating,
          reviewedAt: row.readTable(history).reviewDateTime.toLocal(),
          durationMs: row.readTable(history).reviewDuration,
          state: row.readTable(word).cardState,
          stability: row.readTable(word).cardStability,
          difficulty: row.readTable(word).cardDifficulty,
        ),
    ];
  }

  /// Counts studied cards whose due time falls on each day of `[start, end)`.
  Future<Map<DateTime, int>> _dueCountsByDay(
    LanguageCode language,
    DateTime start,
    DateTime end,
  ) async {
    final due = _database.wordTable.cardDueTime;
    final query = _database.selectOnly(_database.wordTable)
      ..addColumns(<Expression<Object>>[due])
      ..where(
        Expression.and(<Expression<bool>>[
          _database.wordTable.languageCode.equals(language.name),
          _database.wordTable.cardLastReviewTime.isNotNull(),
          due.isBiggerOrEqualValue(start.toUtc()),
          due.isSmallerThanValue(end.toUtc()),
        ]),
      );
    final rows = await query.get();
    final Map<DateTime, int> counts = <DateTime, int>{};
    for (final row in rows) {
      final DateTime? value = row.read(due);
      if (value == null) {
        continue;
      }
      final DateTime day = dayStart(value.toLocal());
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  /// Words due on [day], capped at [_dueListLimit].
  Future<List<DueEntry>> _dueWordsOnDay(
    LanguageCode language,
    DateTime day,
  ) async {
    final query = _database.select(_database.wordTable)
      ..where(
        (t) => Expression.and(<Expression<bool>>[
          t.languageCode.equals(language.name),
          t.cardLastReviewTime.isNotNull(),
          t.cardDueTime.isBiggerOrEqualValue(day.toUtc()),
          t.cardDueTime.isSmallerThanValue(nextDay(day).toUtc()),
        ]),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.cardDueTime)])
      ..limit(_dueListLimit);
    final rows = await query.get();
    return <DueEntry>[
      for (final row in rows)
        DueEntry(
          cardId: row.cardId,
          word: row.originalWord,
          translation: row.originalTranslation,
          due: row.cardDueTime.toLocal(),
          state: row.cardState,
          stability: row.cardStability,
          difficulty: row.cardDifficulty,
        ),
    ];
  }

  Future<int> _countWords(
    LanguageCode language,
    Expression<bool>? extra,
  ) async {
    final count = _database.wordTable.id.count();
    final conditions = <Expression<bool>>[
      _database.wordTable.languageCode.equals(language.name),
      ?extra,
    ];
    final row =
        await (_database.selectOnly(_database.wordTable)
              ..addColumns(<Expression<Object>>[count])
              ..where(Expression.and(conditions)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _totalReviews(LanguageCode language) async {
    final history = _database.wordLearningHistoryTable;
    final word = _database.wordTable;
    final count = history.id.count();
    final query =
        (_database.selectOnly(
            history,
          )..addColumns(<Expression<Object>>[count])).join(<Join>[
            innerJoin(word, word.cardId.equalsExp(history.cardId)),
          ])
          ..where(word.languageCode.equals(language.name));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Consecutive studied days ending today (or yesterday when today is empty).
  Future<int> _streakDays(LanguageCode language) async {
    final DateTime today = dayStart(DateTime.now());
    final DateTime from = DateTime(today.year, today.month, today.day - 90);
    final history = _database.wordLearningHistoryTable;
    final word = _database.wordTable;
    final query =
        (_database.selectOnly(
            history,
          )..addColumns(<Expression<Object>>[history.reviewDateTime])).join(
            <Join>[innerJoin(word, word.cardId.equalsExp(history.cardId))],
          )
          ..where(
            Expression.and(<Expression<bool>>[
              word.languageCode.equals(language.name),
              history.reviewDateTime.isBiggerOrEqualValue(from.toUtc()),
            ]),
          );
    final rows = await query.get();
    final Set<DateTime> days = <DateTime>{
      for (final row in rows)
        if (row.read(history.reviewDateTime) != null)
          dayStart(row.read(history.reviewDateTime)!.toLocal()),
    };

    DateTime cursor = days.contains(today)
        ? today
        : DateTime(today.year, today.month, today.day - 1);
    int streak = 0;
    while (days.contains(cursor)) {
      streak += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }
}
