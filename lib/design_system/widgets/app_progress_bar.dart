import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// The single, reusable progress bar for the app (CLAUDE.md §5 — progression
/// visuals are shared design-system components, never one-off per screen). A
/// pill-rounded track with a smoothly animated fill, used for XP, quests and any
/// future goal-gradient bar.
class AppProgressBar extends StatelessWidget {
  /// 0..1 fill. Clamped defensively.
  final double value;

  /// Fill colour; defaults to the brand primary. Pass [AppColors.accent] etc.
  /// for a "complete" emphasis.
  final Color color;

  final double minHeight;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.minHeight = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      // Implicit animation gives progress a satisfying, restrained motion when
      // a logged session nudges a bar forward (§5: polished, never janky).
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1).toDouble()),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, animated, _) => LinearProgressIndicator(
          value: animated,
          minHeight: minHeight,
          backgroundColor: AppColors.outline,
          color: color,
        ),
      ),
    );
  }
}
