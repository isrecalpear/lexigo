/// Small formatting helpers shared by the records page and its widgets.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fsrs/fsrs.dart' as fsrs;

// Project imports:
import 'package:lexigo/l10n/l10n.dart';

/// Localized label of a review [rating].
String ratingLabel(AppLocalizations l10n, fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => l10n.ratingAgain,
    fsrs.Rating.hard => l10n.ratingHard,
    fsrs.Rating.good => l10n.ratingGood,
    fsrs.Rating.easy => l10n.ratingEasy,
  };
}

/// Accent color used for a review [rating].
Color ratingColor(ColorScheme colors, fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => colors.error,
    fsrs.Rating.hard => colors.tertiary,
    fsrs.Rating.good => colors.primary,
    fsrs.Rating.easy => colors.secondary,
  };
}

/// Icon matching a review [rating].
IconData ratingIcon(fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => Icons.refresh,
    fsrs.Rating.hard => Icons.trending_down,
    fsrs.Rating.good => Icons.check,
    fsrs.Rating.easy => Icons.bolt,
  };
}

/// Localized label of a card [state].
String stateLabel(AppLocalizations l10n, fsrs.State state) {
  return switch (state) {
    fsrs.State.learning => l10n.familiarityLearning,
    fsrs.State.relearning => l10n.familiarityRelearning,
    fsrs.State.review => l10n.familiarityReview,
  };
}

/// Formats a local date and time using the current [MaterialLocalizations].
String formatDateTime(BuildContext context, DateTime value) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final String time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
  );
  return '${localizations.formatMediumDate(value)} $time';
}

/// Circular badge showing how a review was rated.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.size = 34});

  final fsrs.Rating rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = ratingColor(Theme.of(context).colorScheme, rating);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(ratingIcon(rating), color: color, size: size * 0.55),
    );
  }
}
