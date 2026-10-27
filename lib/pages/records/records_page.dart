/// Records tab: a week strip with per-day study details, upcoming forecasts and
/// long running learning statistics.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/records/records_service.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/app_localizations.dart';
import 'package:lexigo/pages/records/records_format.dart';
import 'package:lexigo/pages/records/word_detail_sheet.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/settings.dart';

/// Records and statistics page.
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key, this.active = true});

  /// Whether this tab is currently visible.
  ///
  /// The page lives inside a `PageView`, so it is kept alive when another tab
  /// is shown. It reloads its data when it becomes visible again.
  final bool active;

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final RecordsService _service = RecordsService();

  late LanguageCode _language;
  late DateTime _selectedDay;
  late DateTime _weekStart;
  Future<_RecordsData>? _data;

  @override
  void initState() {
    super.initState();
    final DateTime today = RecordsService.dayStart(DateTime.now());
    _selectedDay = today;
    _weekStart = RecordsService.weekStartOf(today);
    _language = SettingsStore.instance.settings.learningLanguage;
    SettingsStore.instance.addListener(_onSettingsChanged);
    _data = _load();
  }

  @override
  void dispose() {
    SettingsStore.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RecordsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      // The page is being rebuilt right after this callback, so assigning the
      // new future is enough; no setState needed.
      _data = _load();
    }
  }

  void _onSettingsChanged() {
    final LanguageCode language =
        SettingsStore.instance.settings.learningLanguage;
    if (language == _language || !mounted) {
      return;
    }
    _language = language;
    _refresh();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    setState(() {
      _data = _load();
    });
  }

  Future<_RecordsData> _load() async {
    try {
      final WeekOverview week = await _service.loadWeek(_language, _weekStart);
      final DayReport day = await _service.loadDay(_language, _selectedDay);
      final LearningStats stats = await _service.loadStats(_language);
      return _RecordsData(week: week, day: day, stats: stats);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load records',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = RecordsService.dayStart(day);
      _data = _load();
    });
  }

  /// Moves the selection by [delta] days, following the week boundary.
  void _shiftDay(int delta) {
    final DateTime next = RecordsService.dayStart(
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + delta),
    );
    setState(() {
      _selectedDay = next;
      _weekStart = RecordsService.weekStartOf(next);
      _data = _load();
    });
  }

  /// Moves the selection by [delta] weeks while keeping the same weekday.
  void _shiftWeek(int delta) {
    final DateTime next = RecordsService.dayStart(
      DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day + delta * 7,
      ),
    );
    setState(() {
      _selectedDay = next;
      _weekStart = RecordsService.weekStartOf(next);
      _data = _load();
    });
  }

  void _handleSwipe(
    DragEndDetails details, {
    required VoidCallback next,
    required VoidCallback previous,
  }) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity < -150) {
      next();
    } else if (velocity > 150) {
      previous();
    }
  }

  void _swipeWeek(DragEndDetails details) {
    _handleSwipe(
      details,
      next: () => _shiftWeek(1),
      previous: () => _shiftWeek(-1),
    );
  }

  void _swipeDay(DragEndDetails details) {
    _handleSwipe(
      details,
      next: () => _shiftDay(1),
      previous: () => _shiftDay(-1),
    );
  }

  Future<void> _openWord(int cardId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          WordDetailSheet(cardId: cardId, service: _service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_RecordsData>(
          future: _data,
          builder:
              (BuildContext context, AsyncSnapshot<_RecordsData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _ErrorView(
                    message: l10n.recordsLoadFailed,
                    retryLabel: l10n.recordsRetry,
                    onRetry: _refresh,
                  );
                }
                final _RecordsData data = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    final Future<_RecordsData> next = _load();
                    if (mounted) {
                      setState(() {
                        _data = next;
                      });
                    }
                    try {
                      await next;
                    } catch (_) {
                      // The FutureBuilder renders the error state.
                    }
                  },
                  child: GestureDetector(
                    // Everything except the week strip changes the selected
                    // day; the week strip installs its own detector and wins
                    // the gesture arena for horizontal drags inside it.
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: _swipeDay,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: <Widget>[
                        _buildWeekHeader(context),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragEnd: _swipeWeek,
                          child: _WeekStrip(
                            week: data.week,
                            selectedDay: _selectedDay,
                            today: RecordsService.dayStart(DateTime.now()),
                            onSelect: _selectDay,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DaySection(report: data.day, onOpenWord: _openWord),
                        const SizedBox(height: 24),
                        _StatsSection(stats: data.stats),
                      ],
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }

  /// Opens a date picker and jumps to the week containing the chosen date.
  Future<void> _pickDate() async {
    final DateTime today = RecordsService.dayStart(DateTime.now());
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(today.year + 10, 12, 31);
    final DateTime initialDate = _selectedDay.isBefore(firstDate)
        ? firstDate
        : _selectedDay.isAfter(lastDate)
        ? lastDate
        : _selectedDay;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: context.l10n.recordsJumpToWeek,
    );
    if (picked == null || !mounted) {
      return;
    }
    final DateTime day = RecordsService.dayStart(picked);
    setState(() {
      _weekStart = RecordsService.weekStartOf(day);
      _selectedDay = day;
      _data = _load();
    });
  }

  /// Jumps back to today when a different day (or another week) is selected.
  void _goToToday() {
    final DateTime today = RecordsService.dayStart(DateTime.now());
    if (RecordsService.isSameDay(_selectedDay, today)) {
      return;
    }
    setState(() {
      _selectedDay = today;
      _weekStart = RecordsService.weekStartOf(today);
      _data = _load();
    });
  }

  Widget _buildWeekHeader(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime weekEnd = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day + 6,
    );
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () => _shiftWeek(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.recordsPreviousWeek,
        ),
        Expanded(
          child: Tooltip(
            message: l10n.recordsJumpToWeek,
            child: InkWell(
              onTap: _pickDate,
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        '${localizations.formatShortMonthDay(_weekStart)} – '
                        '${localizations.formatShortMonthDay(weekEnd)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _shiftWeek(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.recordsNextWeek,
        ),
        if (!RecordsService.isSameDay(_selectedDay, DateTime.now()))
          IconButton(
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
            tooltip: l10n.recordsBackToToday,
          ),
      ],
    );
  }
}

class _RecordsData {
  const _RecordsData({
    required this.week,
    required this.day,
    required this.stats,
  });

  final WeekOverview week;
  final DayReport day;
  final LearningStats stats;
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.week,
    required this.selectedDay,
    required this.today,
    required this.onSelect,
  });

  final WeekOverview week;
  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return Row(
      children: <Widget>[
        for (final DayOverview day in week.days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayTile(
                day: day,
                weekdayLabel:
                    localizations.narrowWeekdays[day.date.weekday % 7],
                selected: RecordsService.isSameDay(day.date, selectedDay),
                isToday: RecordsService.isSameDay(day.date, today),
                onTap: () => onSelect(day.date),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.weekdayLabel,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DayOverview day;
  final String weekdayLabel;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final int count = day.isFuture ? day.dueCount : day.reviewedCount;
    final Color countColor;
    if (day.isFuture) {
      countColor = colors.primary;
    } else if (day.forgottenCount > 0) {
      countColor = colors.error;
    } else {
      countColor = colors.secondary;
    }
    final Color background = selected
        ? colors.primaryContainer
        : Colors.transparent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colors.primary
                : isToday
                ? colors.primary.withValues(alpha: 0.6)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              weekdayLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: selected ? colors.onPrimaryContainer : colors.onSurface,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count > 0 ? '$count' : '·',
              style: theme.textTheme.labelSmall?.copyWith(
                color: count > 0 ? countColor : colors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.report, required this.onOpenWord});

  final DayReport report;
  final ValueChanged<int> onOpenWord;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final bool isToday = RecordsService.isSameDay(report.date, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                localizations.formatFullDate(report.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.today,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (report.isFuture)
          _FutureDay(report: report, onOpenWord: onOpenWord)
        else
          _PastDay(report: report, onOpenWord: onOpenWord),
      ],
    );
  }
}

class _PastDay extends StatelessWidget {
  const _PastDay({required this.report, required this.onOpenWord});

  final DayReport report;
  final ValueChanged<int> onOpenWord;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (report.reviews.isEmpty) {
      return _EmptyState(
        icon: Icons.event_note_outlined,
        text: l10n.recordsEmptyDay,
      );
    }

    final Set<int> distinctWords = <int>{
      for (final ReviewEntry entry in report.reviews) entry.cardId,
    };
    final int forgotten = report.reviews
        .where((ReviewEntry entry) => entry.isForgotten)
        .length;
    final List<int> durations = <int>[
      for (final ReviewEntry entry in report.reviews)
        if (entry.durationMs != null) entry.durationMs!,
    ];
    final int? averageSeconds = durations.isEmpty
        ? null
        : (durations.reduce((int a, int b) => a + b) / durations.length / 1000)
              .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _SummaryChip(
              icon: Icons.repeat,
              label: l10n.recordsReviewCount(report.reviews.length),
            ),
            _SummaryChip(
              icon: Icons.abc,
              label: l10n.recordsWordCount(distinctWords.length),
            ),
            _SummaryChip(
              icon: Icons.error_outline,
              label: l10n.recordsForgottenCount(forgotten),
              highlight: forgotten > 0,
            ),
            if (averageSeconds != null)
              _SummaryChip(
                icon: Icons.timer_outlined,
                label: l10n.recordsAverageTime(averageSeconds),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final ReviewEntry entry in report.reviews)
          _ReviewTile(entry: entry, onTap: () => onOpenWord(entry.cardId)),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.entry, required this.onTap});

  final ReviewEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.reviewedAt),
    );
    final String? difficulty = entry.difficulty == null
        ? null
        : '${l10n.difficultyLabel} ${entry.difficulty!.toStringAsFixed(1)}';
    final String? stability = entry.stability == null
        ? null
        : '${l10n.stabilityLabel} '
              '${l10n.daysLabel(entry.stability!.toStringAsFixed(1))}';
    final List<String> details = <String>[
      ratingLabel(l10n, entry.rating),
      ?difficulty,
      ?stability,
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RatingBadge(rating: entry.rating),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.word,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.translation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details.join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FutureDay extends StatelessWidget {
  const _FutureDay({required this.report, required this.onOpenWord});

  final DayReport report;
  final ValueChanged<int> onOpenWord;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ForecastMetric(
                value: '${report.dueCount}',
                label: l10n.recordsDueLabel,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ForecastMetric(
                value: '${report.overdueCount}',
                label: l10n.recordsOverdueLabel,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ForecastMetric(
                value: '${report.newWordsRemaining}',
                label: l10n.recordsNewWordsLabel,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.recordsForecastHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.recordsDueListTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (report.dueWords.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.recordsNoDue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final DueEntry entry in report.dueWords)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => onOpenWord(entry.cardId),
                leading: const Icon(Icons.schedule),
                title: Text(entry.word),
                subtitle: Text(entry.translation),
                trailing: Text(
                  localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(entry.due),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ForecastMetric extends StatelessWidget {
  const _ForecastMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final String retention = stats.retention == null
        ? '—'
        : '${(stats.retention! * 100).round()}%';
    final List<Widget> tiles = <Widget>[
      _StatCard(
        icon: Icons.local_fire_department_outlined,
        label: l10n.recordsStreakLabel,
        value: l10n.daysLabel('${stats.streakDays}'),
      ),
      _StatCard(
        icon: Icons.insights_outlined,
        label: l10n.recordsLast7Days,
        value: '${stats.last7DayReviews}',
      ),
      _StatCard(
        icon: Icons.psychology_outlined,
        label: l10n.recordsRetentionLabel,
        value: retention,
      ),
      _StatCard(
        icon: Icons.verified_outlined,
        label: l10n.recordsMasteredLabel,
        value: '${stats.masteredWords}',
      ),
      _StatCard(
        icon: Icons.menu_book_outlined,
        label: l10n.recordsVocabularyLabel,
        value: '${stats.vocabularySize}',
      ),
      _StatCard(
        icon: Icons.history,
        label: l10n.recordsTotalReviewsLabel,
        value: '${stats.totalReviews}',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.recordsOverview, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Keep the tiles compact on wide screens: choose the column count
            // from the available width instead of scaling a two-column grid,
            // which made the cards grow into tall, mostly empty boxes.
            final double width = constraints.maxWidth;
            final int columns = width >= 900
                ? 6
                : width >= 560
                ? 3
                : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 76,
              ),
              itemBuilder: (BuildContext context, int index) => tiles[index],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(l10n.recordsLast7Days, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _WeekBarChart(counts: stats.last7DayCounts),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({required this.counts});

  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int maxCount = counts.fold<int>(1, (int a, int b) => a > b ? a : b);
    final DateTime today = DateTime.now();
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (int index = 0; index < counts.length; index++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    counts[index] == 0 ? '' : '${counts[index]}',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: counts[index] == 0
                        ? 2
                        : 4 + 52 * counts[index] / maxCount,
                    width: 16,
                    decoration: BoxDecoration(
                      color: index == counts.length - 1
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.narrowWeekdays[DateTime(
                          today.year,
                          today.month,
                          today.day - (counts.length - 1 - index),
                        ).weekday %
                        7],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = highlight ? colors.error : colors.onSurfaceVariant;
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      side: BorderSide(color: colors.outlineVariant),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 32, color: colors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 36,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
