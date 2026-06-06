import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/streak.dart';

/// Compact, motivating streak summary. Adapts its message to the three states:
/// no streak yet, alive but not logged today (gentle nudge), and active today.
class StreakBanner extends StatelessWidget {
  final Streak streak;

  const StreakBanner({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak.current > 0;
    final flameColor = streak.activeToday
        ? AppColors.primary
        : (hasStreak ? AppColors.draw : AppColors.textSecondary);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: flameColor, size: 36),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title(), style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(_subtitle(), style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title() {
    if (streak.current == 0) return 'Start a streak';
    final unit = streak.current == 1 ? 'day' : 'days';
    return '${streak.current}-$unit streak';
  }

  String _subtitle() {
    if (streak.current == 0) {
      return 'Log a session today to get started.';
    }
    if (!streak.activeToday) {
      return 'Play today to keep it alive. Best: ${streak.longest} days.';
    }
    return 'Logged today — nice. Best: ${streak.longest} days.';
  }
}
