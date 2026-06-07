import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_text_styles.dart';

/// One axis of a [SkillRadarChart]: a label and its 0..1 value.
class RadarEntry {
  final String label;

  /// 0..1 along the axis (0 = centre, 1 = outer ring).
  final double value;

  const RadarEntry({required this.label, required this.value});
}

/// A dependency-free radar/spider chart — the visual centrepiece of the Player
/// Profile (★ section). Reusable design-system component (CLAUDE.md §5:
/// progression visuals are reusable, never one-off). Renders concentric grid
/// rings, axis spokes, labelled axes and the filled value polygon.
///
/// Pure presentation: it takes already-computed [entries]; no business logic.
class SkillRadarChart extends StatelessWidget {
  final List<RadarEntry> entries;

  /// Number of concentric grid rings (excluding the centre).
  final int rings;

  const SkillRadarChart({super.key, required this.entries, this.rings = 4});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RadarPainter(entries: entries, rings: rings),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<RadarEntry> entries;
  final int rings;

  _RadarPainter({required this.entries, required this.rings});

  static const double _labelGutter = 30; // space reserved for axis labels

  @override
  void paint(Canvas canvas, Size size) {
    final n = entries.length;
    if (n < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _labelGutter;
    if (radius <= 0) return;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.outline;

    // Concentric grid rings.
    for (var r = 1; r <= rings; r++) {
      final t = r / rings;
      canvas.drawPath(_polygon(center, radius * t, n), gridPaint);
    }

    // Axis spokes.
    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, _vertex(center, radius, i, n), gridPaint);
    }

    // Value polygon.
    final valuePath = Path();
    for (var i = 0; i < n; i++) {
      final v = entries[i].value.clamp(0.0, 1.0);
      final p = _vertex(center, radius * v, i, n);
      if (i == 0) {
        valuePath.moveTo(p.dx, p.dy);
      } else {
        valuePath.lineTo(p.dx, p.dy);
      }
    }
    valuePath.close();

    canvas.drawPath(
      valuePath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.primary.withOpacity(0.18),
    );
    canvas.drawPath(
      valuePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );

    // Vertex dots + labels.
    final dotPaint = Paint()..color = AppColors.primary;
    for (var i = 0; i < n; i++) {
      final v = entries[i].value.clamp(0.0, 1.0);
      canvas.drawCircle(_vertex(center, radius * v, i, n), 3, dotPaint);
      _paintLabel(canvas, center, radius, i, n, entries[i].label);
    }
  }

  Path _polygon(Offset center, double r, int n) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final p = _vertex(center, r, i, n);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  Offset _vertex(Offset center, double r, int i, int n) {
    final angle = -math.pi / 2 + i * 2 * math.pi / n;
    return Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    int i,
    int n,
    String label,
  ) {
    final angle = -math.pi / 2 + i * 2 * math.pi / n;
    final anchor = Offset(
      center.dx + (radius + 14) * math.cos(angle),
      center.dy + (radius + 14) * math.sin(angle),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 84);

    // Horizontal anchoring: snap left/centre/right by the axis direction so the
    // label sits cleanly outside the chart rather than overlapping it.
    final cos = math.cos(angle);
    double dx;
    if (cos.abs() < 0.3) {
      dx = anchor.dx - tp.width / 2; // top/bottom axes → centred
    } else if (cos > 0) {
      dx = anchor.dx; // right side → left-aligned to anchor
    } else {
      dx = anchor.dx - tp.width; // left side → right-aligned to anchor
    }
    final dy = anchor.dy - tp.height / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.entries != entries || old.rings != rings;
}
