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
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: FutureBuilder<CardInsight?>(
          future: _future,
          builder:
              (BuildContext context, AsyncSnapshot<CardInsight?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final CardInsight? insight = snapshot.data;
                if (insight == null) {
                  return Center(child: Text(context.l10n.recordsUnavailable));
                }
                return _WordDetailContent(
                  insight: insight,
                  onClose: () => Navigator.of(context).pop(),
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
    final ColorScheme colors = Theme.of(context).colorScheme;
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    word.originalWord,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.originalTranslation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            Chip(label: Text(stateLabel(l10n, card.state))),
            if (difficulty != null)
              Chip(
                label: Text(
                  '${l10n.difficultyLabel} ${difficulty.toStringAsFixed(1)}',
                ),
              ),
            if (stability != null)
              Chip(
                label: Text(
                  '${l10n.stabilityLabel} '
                  '${l10n.daysLabel(stability.toStringAsFixed(1))}',
                ),
              ),
          ],
        ),
        if (word.exampleSentence.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(word.exampleSentence),
                if (word.exampleTranslation.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    word.exampleTranslation,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (stability != null && lastReview != null) ...<Widget>[
          Row(
            children: <Widget>[
              Text(
                l10n.forgettingCurve,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (probability != null)
                Text(
                  l10n.currentRetrievability((probability * 100).round()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ForgettingCurveChart(stability: stability, lastReview: lastReview),
        ] else
          Text(
            l10n.neverReviewed,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        const SizedBox(height: 16),
        _InfoRow(
          label: l10n.nextReviewLabel,
          value: formatDateTime(context, card.due.toLocal()),
        ),
        _InfoRow(
          label: l10n.lastReviewLabel,
          value: lastReview == null ? '—' : formatDateTime(context, lastReview),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.cardHistoryTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        if (insight.history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.noCardHistory,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          )
        else
          for (final CardReview review in insight.history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: RatingBadge(rating: review.rating),
              title: Text(ratingLabel(l10n, review.rating)),
              subtitle: Text(formatDateTime(context, review.reviewedAt)),
              trailing: review.durationMs == null
                  ? null
                  : Text(
                      '${(review.durationMs! / 1000).round()}s',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
            ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
