/// Bottom sheet with the FSRS state, forgetting curve and review history of a
/// single word.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/records/records_service.dart';
import 'package:lexigo/l10n/l10n.dart';
import 'package:lexigo/pages/records/forgetting_curve.dart';
import 'package:lexigo/pages/records/records_format.dart';
import 'package:lexigo/pages/widgets/app_ui.dart';
import 'package:lexigo/theme/app_theme.dart';

/// Opens the detail sheet for [cardId] using [service] for the queries.
class WordDetailSheet extends StatefulWidget {
  const WordDetailSheet({
    super.key,
    required this.cardId,
    required this.service,
  });

  final int cardId;
  final RecordsService service;

  @override
  State<WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends State<WordDetailSheet> {
  late final Future<CardInsight?> _future = widget.service.loadCardInsight(
    widget.cardId,
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: FutureBuilder<CardInsight?>(
          future: _future,
          builder:
              (BuildContext context, AsyncSnapshot<CardInsight?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppContent(child: AppLoading());
                }
                final CardInsight? insight = snapshot.data;
                if (insight == null) {
                  return AppContent(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: l10n.recordsUnavailable,
                          compact: true,
                        ),
                      ),
                    ),
                  );
                }
                return AppContent(
                  child: _WordDetailContent(
                    insight: insight,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
              },
        ),
      ),
    );
  }
}

class _WordDetailContent extends StatelessWidget {
  const _WordDetailContent({required this.insight, required this.onClose});

  final CardInsight insight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final word = insight.word;
    final card = word.card;
    final double? stability = card.stability;
    final double? difficulty = card.difficulty;
    final DateTime? lastReview = card.lastReview?.toLocal();
    final double? probability = RecordsService.retrievabilityAt(
      stability: stability,
      lastReview: lastReview,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxs,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    word.originalWord,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    word.originalTranslation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            AppPill(
              icon: Icons.auto_awesome_rounded,
              label: stateLabel(l10n, card.state),
              color: colors.onPrimaryContainer,
              backgroundColor: colors.primaryContainer,
            ),
            if (difficulty != null)
              AppPill(
                icon: Icons.speed_rounded,
                label:
                    '${l10n.difficultyLabel} '
                    '${difficulty.toStringAsFixed(1)}',
                color: colors.onTertiaryContainer,
                backgroundColor: colors.tertiaryContainer,
              ),
            if (stability != null)
              AppPill(
                icon: Icons.timelapse_rounded,
                label:
                    '${l10n.stabilityLabel} '
                    '${l10n.daysLabel(stability.toStringAsFixed(1))}',
                color: colors.onSecondaryContainer,
                backgroundColor: colors.secondaryContainer,
              ),
          ],
        ),
        if (word.exampleSentence.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          AppSectionHeader(title: l10n.fieldOriginalExample),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  word.exampleSentence,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                if (word.exampleTranslation.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    word.exampleTranslation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(
          title: l10n.forgettingCurve,
          trailing: probability == null
              ? null
              : AppPill(
                  icon: Icons.insights_rounded,
                  label: l10n.currentRetrievability(
                    (probability * 100).round(),
                  ),
                  color: colors.onPrimaryContainer,
                  backgroundColor: colors.primaryContainer,
                ),
        ),
        if (stability != null && lastReview != null)
          AppSurface(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xxs,
            ),
            child: ForgettingCurveChart(
              stability: stability,
              lastReview: lastReview,
            ),
          )
        else
          AppSurface(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.timeline_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.neverReviewed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          child: Column(
            children: <Widget>[
              _InfoRow(
                label: l10n.nextReviewLabel,
                value: formatDateTime(context, card.due.toLocal()),
              ),
              const Divider(height: 1),
              _InfoRow(
                label: l10n.lastReviewLabel,
                value: lastReview == null
                    ? '—'
                    : formatDateTime(context, lastReview),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(title: l10n.cardHistoryTitle),
        if (insight.history.isEmpty)
          AppEmptyState(
            icon: Icons.history_rounded,
            title: l10n.noCardHistory,
            compact: true,
          )
        else
          AppSurface(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < insight.history.length;
                  index++
                ) ...<Widget>[
                  if (index > 0)
                    const Divider(
                      height: 1,
                      indent: 56,
                      endIndent: AppSpacing.md,
                    ),
                  _HistoryRow(review: insight.history[index]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// One review event inside the grouped history card.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.review});

  final CardReview review;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          RatingBadge(rating: review.rating, size: 32),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ratingLabel(l10n, review.rating),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  formatDateTime(context, review.reviewedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (review.durationMs != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${(review.durationMs! / 1000).round()}s',
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Label / value row used for the next and last review timestamps.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
