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

/// Tonal container background for a review [rating].
///
/// Each rating maps onto a Material 3 container role so the accent colors stay
/// inside the active [ColorScheme].
Color ratingContainerColor(ColorScheme colors, fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => colors.errorContainer,
    fsrs.Rating.hard => colors.tertiaryContainer,
    fsrs.Rating.good => colors.primaryContainer,
    fsrs.Rating.easy => colors.secondaryContainer,
  };
}

/// Content color paired with [ratingContainerColor].
Color ratingOnColor(ColorScheme colors, fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => colors.onErrorContainer,
    fsrs.Rating.hard => colors.onTertiaryContainer,
    fsrs.Rating.good => colors.onPrimaryContainer,
    fsrs.Rating.easy => colors.onSecondaryContainer,
  };
}

/// Tonal container background for a card [state].
Color stateContainerColor(ColorScheme colors, fsrs.State state) {
  return switch (state) {
    fsrs.State.learning => colors.errorContainer,
    fsrs.State.relearning => colors.tertiaryContainer,
    fsrs.State.review => colors.primaryContainer,
  };
}

/// Content color paired with [stateContainerColor].
Color stateOnColor(ColorScheme colors, fsrs.State state) {
  return switch (state) {
    fsrs.State.learning => colors.onErrorContainer,
    fsrs.State.relearning => colors.onTertiaryContainer,
    fsrs.State.review => colors.onPrimaryContainer,
  };
}

/// Icon matching a review [rating].
IconData ratingIcon(fsrs.Rating rating) {
  return switch (rating) {
    fsrs.Rating.again => Icons.refresh_rounded,
    fsrs.Rating.hard => Icons.trending_down_rounded,
    fsrs.Rating.good => Icons.check_rounded,
    fsrs.Rating.easy => Icons.bolt_rounded,
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ratingContainerColor(colors, rating),
        shape: BoxShape.circle,
      ),
      child: Icon(
        ratingIcon(rating),
        color: ratingOnColor(colors, rating),
        size: size * 0.55,
      ),
    );
  }
}
