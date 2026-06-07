import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/badge.dart';
import 'badge_visuals.dart';

/// Renders one [Achievement] with explicit earned / locked states (do-not-break
/// rule #5). Locked badges are dimmed and show progress toward the threshold —
/// motivating, not punishing.
///
/// Uses the raster badge asset from assets/images/brand/badges/ when available
/// (via [badgeAssetFor]); falls back to the Material icon from [badgeIconFor].
class BadgeTile extends StatelessWidget {
  final Achievement achievement;

  const BadgeTile({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;
    final color = earned ? AppColors.primary : AppColors.textSecondary;
    final assetPath = badgeAssetFor(achievement.badge.id);

    return Opacity(
      opacity: earned ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: earned
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: earned ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // PNG asset when available; icon otherwise.
                if (assetPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: Image.asset(
                      assetPath,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Icon(badgeIconFor(achievement.badge.id), color: color),
                const Spacer(),
                if (earned)
                  const Icon(Icons.check_circle,
                      size: 18, color: AppColors.success)
                else
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.badge.title,
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              achievement.badge.description,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!earned) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${achievement.currentValue}/${achievement.badge.threshold}',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
