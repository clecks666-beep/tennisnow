import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// A small, dependency-free line chart (sparkline) for short value series such
/// as the performance trend. Drawn with CustomPainter so it stays lightweight
/// and on-brand (CLAUDE.md §5/§6) without pulling in a charting package.
///
/// Values are clamped to [minValue]..[maxValue] (default 1..5). The caller is
/// responsible for the empty case (show an EmptyState instead).
class MiniLineChart extends StatelessWidget {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final double height;

  const MiniLineChart({
    super.key,
    required this.values,
    this.minValue = 1,
    this.maxValue = 5,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          values: values,
          minValue: minValue,
          maxValue: maxValue,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;

  _LineChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 1;
    // Baseline and top gridlines for context.
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), gridPaint);

    if (values.isEmpty) return;

    final range = (maxValue - minValue).abs() < 0.0001
        ? 1.0
        : (maxValue - minValue);

    double dx(int i) =>
        values.length == 1 ? size.width / 2 : size.width * (i / (values.length - 1));
    double dy(double v) {
      final clamped = v.clamp(minValue, maxValue);
      final t = (clamped - minValue) / range; // 0 (bottom) .. 1 (top)
      return size.height - t * size.height;
    }

    // Filled area under the line for a richer, app-like feel.
    final linePath = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(dx(i), dy(values[i]));
      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
      }
    }

    final areaPath = Path.from(linePath)
      ..lineTo(dx(values.length - 1), size.height)
      ..lineTo(dx(0), size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()..color = AppColors.primary.withValues(alpha: 0.10),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots on each data point.
    final dotPaint = Paint()..color = AppColors.primary;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(dx(i), dy(values[i])), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.values != values ||
      old.minValue != minValue ||
      old.maxValue != maxValue;
}
