import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_text_styles.dart';

/// The tennisnow brand mark — a tennis ball drawn purely in code (no raster
/// asset) so it scales crisply at any size, adapts to the theme, and lives in
/// the design system as the single source of brand truth (CLAUDE.md §5/§10).
///
/// Two looks: [tile] true renders the court-green "app-icon" tile with an
/// optic-yellow ball (use on brand surfaces / launch); false renders just the
/// ball for tighter, inline lockups.
class AppLogoMark extends StatelessWidget {
  final double size;
  final bool tile;

  const AppLogoMark({super.key, this.size = 40, this.tile = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter(tile: tile)),
    );
  }
}

/// Horizontal brand lockup: the mark + the "tennisnow" wordmark, with "now"
/// carrying the brand green so the name reads as a single, confident unit.
/// Composed from type tokens (never ad-hoc text styles, §5).
class AppLogo extends StatelessWidget {
  /// Height of the mark; the wordmark scales from it.
  final double height;
  final bool showWordmark;
  final bool tile;

  const AppLogo({
    super.key,
    this.height = 32,
    this.showWordmark = true,
    this.tile = true,
  });

  @override
  Widget build(BuildContext context) {
    final mark = AppLogoMark(size: height, tile: tile);
    if (!showWordmark) return mark;

    final wordSize = height * 0.62;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: height * 0.3),
        Text.rich(
          TextSpan(
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: wordSize,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'tennis'),
              TextSpan(
                text: 'now',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final bool tile;

  _LogoPainter({required this.tile});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);

    // Optional app-icon tile behind the ball.
    if (tile) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final rrect =
          RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28));
      canvas.drawRRect(rrect, Paint()..color = AppColors.primary);
    }

    final ballRadius = s * (tile ? 0.30 : 0.46);
    final ballPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(center, ballRadius, ballPaint);

    // On a light surface the bare ball needs a hairline so it doesn't float.
    if (!tile) {
      canvas.drawCircle(
        center,
        ballRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.035
          ..color = AppColors.primary.withOpacity(0.25),
      );
    }

    // The seam — a single confident curve, clipped to the ball so it reads as a
    // real tennis ball at any size. Dark green for crisp contrast on the yellow.
    final r = ballRadius;
    final seam = Path()
      ..moveTo(center.dx + r * 0.18, center.dy - r)
      ..cubicTo(
        center.dx - r * 0.78,
        center.dy - r * 0.42,
        center.dx - r * 0.78,
        center.dy + r * 0.42,
        center.dx + r * 0.18,
        center.dy + r,
      );

    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: center, radius: ballRadius)));
    canvas.drawPath(
      seam,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.20
        ..strokeCap = StrokeCap.round
        ..color = tile ? AppColors.primaryDark : AppColors.primary,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.tile != tile;
}
