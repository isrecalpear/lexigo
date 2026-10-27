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
/// the 90% retention target (which FSRS places at exactly `stability` days).
class ForgettingCurveChart extends StatelessWidget {
  const ForgettingCurveChart({
    super.key,
    required this.stability,
    required this.lastReview,
    this.now,
  });

  final double stability;
  final DateTime lastReview;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: CustomPaint(
        painter: _ForgettingCurvePainter(
          stability: stability,
          lastReview: lastReview,
          now: now ?? DateTime.now(),
          curveColor: colors.primary,
          gridColor: colors.outlineVariant,
          textColor: colors.onSurfaceVariant,
          retentionColor: colors.tertiary,
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
    required this.gridColor,
    required this.textColor,
    required this.retentionColor,
  });

  final double stability;
  final DateTime lastReview;
  final DateTime now;
  final Color curveColor;
  final Color gridColor;
  final Color textColor;
  final Color retentionColor;

  static const double _leftPadding = 34;
  static const double _bottomPadding = 22;
  static const double _topPadding = 8;
  static const double _rightPadding = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect plot = Rect.fromLTRB(
      _leftPadding,
      _topPadding,
      size.width - _rightPadding,
      size.height - _bottomPadding,
    );
    final double elapsedDays = now.difference(lastReview).inMinutes / (60 * 24);
    final double horizon = math.min(
      365,
      math.max(14, math.max(stability * 3, elapsedDays * 1.25)),
    );

    _paintGrid(canvas, plot);
    _paintAxisLabels(canvas, plot, horizon);
    _paintRetentionMarker(canvas, plot, horizon);
    _paintCurve(canvas, plot, horizon);
    _paintCurrentMarker(canvas, plot, horizon, elapsedDays);
  }

  void _paintGrid(Canvas canvas, Rect plot) {
    final Paint gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (final double level in <double>[0, 0.5, 0.9, 1]) {
      final double y = plot.bottom - plot.height * level;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintText(
        canvas,
        '${(level * 100).round()}%',
        Offset(0, y - 6),
        alignRight: false,
      );
    }
  }

  void _paintAxisLabels(Canvas canvas, Rect plot, double horizon) {
    _paintText(canvas, '0', Offset(plot.left, plot.bottom + 5));
    _paintText(
      canvas,
      '${horizon.round()}d',
      Offset(plot.right - 24, plot.bottom + 5),
    );
  }

  void _paintRetentionMarker(Canvas canvas, Rect plot, double horizon) {
    if (stability <= 0 || stability > horizon) {
      return;
    }
    final double x = plot.left + plot.width * stability / horizon;
    final Paint paint = Paint()
      ..color = retentionColor.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    const double dash = 4;
    for (double y = plot.top; y < plot.bottom; y += dash * 2) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dash, plot.bottom)),
        paint,
      );
    }
  }

  void _paintCurve(Canvas canvas, Rect plot, double horizon) {
    final Path path = Path();
    const int samples = 100;
    for (int i = 0; i <= samples; i++) {
      final double days = horizon * i / samples;
      final double probability = RecordsService.retrievability(stability, days);
      final Offset point = Offset(
        plot.left + plot.width * (days / horizon),
        plot.bottom - plot.height * probability,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = curveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintCurrentMarker(
    Canvas canvas,
    Rect plot,
    double horizon,
    double elapsedDays,
  ) {
    final double clamped = math.min(elapsedDays, horizon);
    final double probability = RecordsService.retrievability(
      stability,
      elapsedDays,
    );
    final Offset point = Offset(
      plot.left + plot.width * (clamped / horizon),
      plot.bottom - plot.height * probability,
    );
    canvas.drawCircle(
      point,
      6,
      Paint()..color = curveColor.withValues(alpha: 0.25),
    );
    canvas.drawCircle(point, 3.5, Paint()..color = curveColor);
    canvas.drawLine(
      Offset(point.dx, plot.bottom),
      point,
      Paint()
        ..color = curveColor.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    bool alignRight = true,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 10, color: textColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double dx = alignRight ? offset.dx - painter.width : offset.dx;
    painter.paint(canvas, Offset(math.max(0, dx), offset.dy));
  }

  @override
  bool shouldRepaint(_ForgettingCurvePainter oldDelegate) {
    return oldDelegate.stability != stability ||
        oldDelegate.lastReview != lastReview ||
        oldDelegate.now != now ||
        oldDelegate.curveColor != curveColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.retentionColor != retentionColor;
  }
}
