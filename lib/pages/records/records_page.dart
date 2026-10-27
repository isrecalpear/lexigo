/// Records tab: a week strip with per-day study details, upcoming forecasts and
/// long running learning statistics.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/records/records_service.dart';
import 'package:lexigo/backend/word.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/records/records_format.dart';
import 'package:lexigo/pages/records/word_detail_sheet.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';
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
    // The global shell already owns the top bar, so the tab only needs to keep
    // the horizontal/bottom insets safe.
    return Scaffold(
      body: SafeArea(
        top: false,
        child: FutureBuilder<_RecordsData>(
          future: _data,
          builder:
              (BuildContext context, AsyncSnapshot<_RecordsData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const AppContent(child: AppLoading());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return AppContent(
                    child: AppErrorView(
                      message: l10n.recordsLoadFailed,
                      retryLabel: l10n.recordsRetry,
                      onRetry: _refresh,
                    ),
                  );
                }
                final _RecordsData data = snapshot.data!;
                final DateTime today = RecordsService.dayStart(DateTime.now());
                return AppContent(
                  child: RefreshIndicator(
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
                        padding: AppInsets.page,
                        children: <Widget>[
                          _buildPageHeader(context),
                          const SizedBox(height: AppSpacing.xxs),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragEnd: _swipeWeek,
                            child: _WeekStrip(
                              week: data.week,
                              selectedDay: _selectedDay,
                              today: today,
                              onSelect: _selectDay,
                              onPickDate: _pickDate,
                              onPreviousWeek: () => _shiftWeek(-1),
                              onNextWeek: () => _shiftWeek(1),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (data.day.isFuture)
                            _FutureDay(report: data.day, onOpenWord: _openWord)
                          else
                            _PastDay(report: data.day, onOpenWord: _openWord),
                          const SizedBox(height: AppSpacing.xxl),
                          _StatsSection(stats: data.stats),
                        ],
                      ),
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }

  /// Page header with the selected day context and a "back to today" action.
  Widget _buildPageHeader(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime today = RecordsService.dayStart(DateTime.now());
    final bool isToday = RecordsService.isSameDay(_selectedDay, today);
    return AppPageHeader(
      eyebrow: l10n.tabRecords,
      title: isToday
          ? l10n.today
          : localizations.formatMediumDate(_selectedDay),
      subtitle: localizations.formatFullDate(_selectedDay),
      actions: <Widget>[
        if (!isToday)
          IconButton(
            onPressed: _goToToday,
            icon: const Icon(Icons.today_rounded),
            tooltip: l10n.recordsBackToToday,
          ),
      ],
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

/// Rounded calendar card with the week navigation row and the seven day tiles.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.week,
    required this.selectedDay,
    required this.today,
    required this.onSelect,
    required this.onPickDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final WeekOverview week;
  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPickDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime weekStart = week.weekStart;
    final DateTime weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
    );
    final String rangeLabel =
        '${localizations.formatShortMonthDay(weekStart)} – '
        '${localizations.formatShortMonthDay(weekEnd)}';

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: l10n.recordsPreviousWeek,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Tooltip(
                  message: l10n.recordsJumpToWeek,
                  child: InkWell(
                    onTap: onPickDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              rangeLabel,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: l10n.recordsNextWeek,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: <Widget>[
              for (final DayOverview day in week.days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
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
          ),
        ],
      ),
    );
  }
}

/// One day cell of the week strip with an animated selection pill.
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
    final bool hasForgotten = !day.isFuture && day.forgottenCount > 0;
    final Color selectedForeground = colors.onPrimaryContainer;
    final Color foreground = selected ? selectedForeground : colors.onSurface;
    final Color labelColor = selected
        ? selectedForeground
        : colors.onSurfaceVariant;
    final Color countColor;
    if (hasForgotten) {
      countColor = colors.error;
    } else if (selected) {
      countColor = selectedForeground;
    } else if (day.isFuture) {
      countColor = colors.primary;
    } else {
      countColor = colors.secondary;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            width: selected ? 1.4 : 1,
            color: selected || isToday ? colors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              weekdayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: labelColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.date.day}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: selected || isToday
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count > 0 ? '$count' : '·',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: count > 0
                    ? countColor
                    : selected
                    ? selectedForeground
                    : colors.outline,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Review log of a past day (or today), with a compact summary pill row.
class _PastDay extends StatelessWidget {
  const _PastDay({required this.report, required this.onOpenWord});

  final DayReport report;
  final ValueChanged<int> onOpenWord;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ColorScheme colors = Theme.of(context).colorScheme;
    if (report.reviews.isEmpty) {
      return AppEmptyState(
        icon: Icons.event_note_outlined,
        title: l10n.recordsEmptyDay,
        compact: true,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            AppPill(
              icon: Icons.repeat_rounded,
              label: l10n.recordsReviewCount(report.reviews.length),
              color: colors.onPrimaryContainer,
              backgroundColor: colors.primaryContainer,
            ),
            AppPill(
              icon: Icons.text_fields_rounded,
              label: l10n.recordsWordCount(distinctWords.length),
              color: colors.onSecondaryContainer,
              backgroundColor: colors.secondaryContainer,
            ),
            AppPill(
              icon: Icons.error_outline_rounded,
              label: l10n.recordsForgottenCount(forgotten),
              color: forgotten > 0
                  ? colors.onErrorContainer
                  : colors.onSurfaceVariant,
              backgroundColor: forgotten > 0
                  ? colors.errorContainer
                  : colors.surfaceContainerHighest,
            ),
            if (averageSeconds != null)
              AppPill(
                icon: Icons.timer_outlined,
                label: l10n.recordsAverageTime(averageSeconds),
                color: colors.onSurfaceVariant,
                backgroundColor: colors.surfaceContainerHighest,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(title: l10n.cardHistoryTitle),
        for (final ReviewEntry entry in report.reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _ReviewTile(
              entry: entry,
              onTap: () => onOpenWord(entry.cardId),
            ),
          ),
      ],
    );
  }
}

/// Rounded review row showing rating, word, time and FSRS details.
class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.entry, required this.onTap});

  final ReviewEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
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
    return AppSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      onTap: onTap,
      semanticLabel: '${entry.word}, ${entry.translation}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RatingBadge(rating: entry.rating, size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      time,
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.translation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    _MetaChip(
                      icon: ratingIcon(entry.rating),
                      label: ratingLabel(l10n, entry.rating),
                      color: ratingColor(colors, entry.rating),
                    ),
                    if (difficulty != null)
                      _MetaChip(icon: Icons.speed_rounded, label: difficulty),
                    if (stability != null)
                      _MetaChip(
                        icon: Icons.timelapse_rounded,
                        label: stability,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small tonal pill used for the FSRS details of a review row.
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color accent = color ?? colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Forecast of an upcoming day: three tonal metrics and the due word list.
class _FutureDay extends StatelessWidget {
  const _FutureDay({required this.report, required this.onOpenWord});

  final DayReport report;
  final ValueChanged<int> onOpenWord;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _ForecastMetric(
                  icon: Icons.event_repeat_rounded,
                  value: '${report.dueCount}',
                  label: l10n.recordsDueLabel,
                  containerColor: colors.primaryContainer,
                  contentColor: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ForecastMetric(
                  icon: Icons.warning_amber_rounded,
                  value: '${report.overdueCount}',
                  label: l10n.recordsOverdueLabel,
                  containerColor: colors.errorContainer,
                  contentColor: colors.onErrorContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ForecastMetric(
                  icon: Icons.auto_awesome_rounded,
                  value: '${report.newWordsRemaining}',
                  label: l10n.recordsNewWordsLabel,
                  containerColor: colors.tertiaryContainer,
                  contentColor: colors.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Text(
                l10n.recordsForecastHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(title: l10n.recordsDueListTitle),
        if (report.dueWords.isEmpty)
          AppEmptyState(
            icon: Icons.event_available_outlined,
            title: l10n.recordsNoDue,
            compact: true,
          )
        else
          for (final DueEntry entry in report.dueWords)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                onTap: () => onOpenWord(entry.cardId),
                // The forecast only shows the word itself: translations are
                // revealed (on request) in the word detail sheet, so browsing
                // the upcoming words does not spoil the recall.
                semanticLabel: entry.word,
                child: Row(
                  children: <Widget>[
                    const AppIconBadge(
                      icon: Icons.schedule_rounded,
                      size: 36,
                      iconSize: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      localizations.formatTimeOfDay(
                        TimeOfDay.fromDateTime(entry.due),
                      ),
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

/// Tonal forecast metric card.
class _ForecastMetric extends StatelessWidget {
  const _ForecastMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.containerColor,
    required this.contentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      color: containerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: contentColor, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: contentColor),
          ),
        ],
      ),
    );
  }
}

/// Learning statistics grid plus the last seven days bar chart.
class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String retention = stats.retention == null
        ? '—'
        : '${(stats.retention! * 100).round()}%';
    final List<Widget> tiles = <Widget>[
      AppStatTile(
        icon: Icons.local_fire_department_rounded,
        label: l10n.recordsStreakLabel,
        value: l10n.daysLabel('${stats.streakDays}'),
        color: colors.tertiary,
      ),
      AppStatTile(
        icon: Icons.insights_rounded,
        label: l10n.recordsLast7DaysShort,
        value: '${stats.last7DayReviews}',
        color: colors.primary,
      ),
      AppStatTile(
        icon: Icons.psychology_alt_rounded,
        label: l10n.recordsRetentionLabel,
        value: retention,
        color: colors.secondary,
      ),
      AppStatTile(
        icon: Icons.verified_rounded,
        label: l10n.recordsMasteredLabel,
        value: '${stats.masteredWords}',
        color: colors.primary,
      ),
      AppStatTile(
        icon: Icons.menu_book_rounded,
        label: l10n.recordsVocabularyLabel,
        value: '${stats.vocabularySize}',
        color: colors.tertiary,
      ),
      AppStatTile(
        icon: Icons.history_rounded,
        label: l10n.recordsTotalReviewsLabel,
        value: '${stats.totalReviews}',
        color: colors.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppSectionHeader(title: l10n.recordsOverview),
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
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                mainAxisExtent: 72,
              ),
              itemBuilder: (BuildContext context, int index) => tiles[index],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(title: l10n.recordsLast7Days),
        AppSurface(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: _WeekBarChart(counts: stats.last7DayCounts),
        ),
      ],
    );
  }
}

/// Seven day review bar chart with rounded primary bars and a today accent.
class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({required this.counts});

  final List<int> counts;

  /// Height reserved for the tallest bar.
  static const double _barMaxHeight = 78;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int maxCount = counts.fold<int>(1, (int a, int b) => a > b ? a : b);
    final DateTime today = DateTime.now();
    final List<String> weekdayLabels = <String>[
      for (int index = 0; index < counts.length; index++)
        localizations.narrowWeekdays[DateTime(
              today.year,
              today.month,
              today.day - (counts.length - 1 - index),
            ).weekday %
            7],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 100,
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
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: index == counts.length - 1
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: index == counts.length - 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        width: 22,
                        height: counts[index] == 0
                            ? 3
                            : 6 +
                                  (_barMaxHeight - 6) *
                                      counts[index] /
                                      maxCount,
                        decoration: BoxDecoration(
                          color: counts[index] == 0
                              ? colors.outlineVariant
                              : index == counts.length - 1
                              ? colors.primary
                              : colors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, color: colors.outlineVariant),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            for (int index = 0; index < weekdayLabels.length; index++)
              Expanded(
                child: Text(
                  weekdayLabels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: index == weekdayLabels.length - 1
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    fontWeight: index == weekdayLabels.length - 1
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
