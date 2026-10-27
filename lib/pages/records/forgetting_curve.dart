/// Forgetting curve visualisation for a single FSRS card.
library;

// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/backend/records/records_service.dart';

/// Draws the FSRS retrievability curve of one word.
///
/// The x axis is days since the last review, the y axis is the probability of
/// recalling the word. A dashed line marks the point where the word drops to
/// the 90% retention target (which FSRS places at exactly `stability` days),
/// and a marker shows the current position of the card on the curve.
class ForgettingCurveChart extends StatelessWidget {
  /// Creates a forgetting curve chart for [stability] and [lastReview].
  const ForgettingCurveChart({
    super.key,
    required this.stability,
    required this.lastReview,
    this.now,
  });

  /// Memory stability in days.
  final double stability;

  /// Local time of the last review.
  final DateTime lastReview;

  /// Reference time, defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextStyle labelStyle =
        (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
          color: colors.onSurfaceVariant,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        );
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: CustomPaint(
        painter: _ForgettingCurvePainter(
          stability: stability,
          lastReview: lastReview,
          now: now ?? DateTime.now(),
          curveColor: colors.primary,
          containerColor: colors.primaryContainer,
          gridColor: colors.outlineVariant,
          retentionColor: colors.tertiary,
          labelStyle: labelStyle,
          emphasisStyle: labelStyle.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ForgettingCurvePainter extends CustomPainter {
  _ForgettingCurvePainter({
    required this.stability,
    required this.lastReview,
    required this.now,
    required this.curveColor,
    required this.containerColor,
    required this.gridColor,
    required this.retentionColor,
    required this.labelStyle,
    required this.emphasisStyle,
  });

  final double stability;
  final DateTime lastReview;
  final DateTime now;
  final Color curveColor;
  final Color containerColor;
  final Color gridColor;
  final Color retentionColor;
  final TextStyle labelStyle;
  final TextStyle emphasisStyle;

  static const double _leftPadding = 44;
  static const double _rightPadding = 14;
  static const double _topPadding = 12;
  static const double _bottomPadding = 24;

  static const double _dash = 3.5;
  static const double _gap = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect plot = Rect.fromLTRB(
      _leftPadding,
      _topPadding,
      size.width - _rightPadding,
      size.height - _bottomPadding,
    );
    if (plot.width <= 0 || plot.height <= 0) {
      return;
    }
    final double elapsedDays = now.difference(lastReview).inMinutes / (60 * 24);
    final double horizon = math.min(
      365,
      math.max(14, math.max(stability * 3, elapsedDays * 1.25)),
    );

    _paintGrid(canvas, plot);
    _paintCurve(canvas, plot, horizon);
    _paintRetentionMarker(canvas, plot, horizon);
    _paintCurrentMarker(canvas, plot, horizon, elapsedDays);
    _paintAxisLabels(canvas, plot, horizon);
  }

  /// Soft dashed horizontal grid lines with their percentage labels.
  void _paintGrid(Canvas canvas, Rect plot) {
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final Paint retentionPaint = Paint()
      ..color = retentionColor
      ..strokeWidth = 1;
    for (final double level in <double>[0, 0.5, 0.9, 1]) {
      final double y = plot.bottom - plot.height * level;
      _drawDashedLine(
        canvas,
        Offset(plot.left, y),
        Offset(plot.right, y),
        level == 0.9 ? retentionPaint : gridPaint,
      );
      _paintText(
        canvas,
        '${(level * 100).round()}%',
        Offset(plot.left - 8, y - 6.5),
        style: level == 0.9 ? emphasisStyle : labelStyle,
        align: TextAlign.right,
      );
    }
  }

  void _paintCurve(Canvas canvas, Rect plot, double horizon) {
    canvas.drawPath(
      _curvePath(plot, horizon),
      Paint()
        ..color = curveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Builds the retrievability curve path for the plot area.
  Path _curvePath(Rect plot, double horizon) {
    final Path path = Path();
    const int samples = 120;
    for (int index = 0; index <= samples; index++) {
      final double days = horizon * index / samples;
      final double probability = RecordsService.retrievability(stability, days);
      final Offset point = Offset(
        plot.left + plot.width * (days / horizon),
        plot.bottom - plot.height * probability,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  /// Dashed marker for the point where the 90% retention target is reached.
  void _paintRetentionMarker(Canvas canvas, Rect plot, double horizon) {
    if (stability <= 0 || stability > horizon) {
      return;
    }
    final double x = plot.left + plot.width * stability / horizon;
    _drawDashedLine(
      canvas,
      Offset(x, plot.top),
      Offset(x, plot.bottom),
      Paint()
        ..color = retentionColor
        ..strokeWidth = 1.2,
    );
    final double probability = RecordsService.retrievability(
      stability,
      stability,
    );
    canvas.drawCircle(
      Offset(x, plot.bottom - plot.height * probability),
      3,
      Paint()..color = retentionColor,
    );
  }

  /// Dashed stem, halo and dot marking the current position on the curve.
  void _paintCurrentMarker(
    Canvas canvas,
    Rect plot,
    double horizon,
    double elapsedDays,
  ) {
    final double clamped = elapsedDays.clamp(0, horizon).toDouble();
    final double probability = RecordsService.retrievability(
      stability,
      clamped,
    );
    final Offset point = Offset(
      plot.left + plot.width * (clamped / horizon),
      plot.bottom - plot.height * probability,
    );
    _drawDashedLine(
      canvas,
      Offset(point.dx, plot.bottom),
      point,
      Paint()
        ..color = gridColor
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(point, 8, Paint()..color = containerColor);
    canvas.drawCircle(point, 4, Paint()..color = curveColor);
  }

  void _paintAxisLabels(Canvas canvas, Rect plot, double horizon) {
    _paintText(
      canvas,
      '0',
      Offset(plot.left, plot.bottom + 6),
      style: labelStyle,
    );
    _paintText(
      canvas,
      '${(horizon / 2).round()}d',
      Offset(plot.left + plot.width / 2, plot.bottom + 6),
      style: labelStyle,
      align: TextAlign.center,
    );
    _paintText(
      canvas,
      '${horizon.round()}d',
      Offset(plot.right, plot.bottom + 6),
      style: labelStyle,
      align: TextAlign.right,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = _dash,
    double gap = _gap,
  }) {
    final double total = (end - start).distance;
    if (total <= 0 || dash <= 0) {
      return;
    }
    final Offset direction = (end - start) / total;
    double current = 0;
    while (current < total) {
      final double next = math.min(current + dash, total);
      canvas.drawLine(
        start + direction * current,
        start + direction * next,
        paint,
      );
      current = next + gap;
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required TextStyle style,
    TextAlign align = TextAlign.left,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double dx = switch (align) {
      TextAlign.center => anchor.dx - painter.width / 2,
      TextAlign.right => anchor.dx - painter.width,
      _ => anchor.dx,
    };
    painter.paint(canvas, Offset(math.max(0, dx), anchor.dy));
  }

  @override
  bool shouldRepaint(_ForgettingCurvePainter oldDelegate) {
    return oldDelegate.stability != stability ||
        oldDelegate.lastReview != lastReview ||
        oldDelegate.now != now ||
        oldDelegate.curveColor != curveColor ||
        oldDelegate.containerColor != containerColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.retentionColor != retentionColor ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.emphasisStyle != emphasisStyle;
  }
}
