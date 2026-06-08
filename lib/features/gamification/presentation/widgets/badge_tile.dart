import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/badge.dart';
import 'badge_visuals.dart';

/// Renders one [Achievement] with explicit earned / locked states (do-not-break
/// rule #5). Locked badges are dimmed and show progress toward the threshold —
/// motivating, not punishing. Rare/epic/legendary badges show a colored accent
/// so progression feels premium and tiered.
class BadgeTile extends StatelessWidget {
  final Achievement achievement;

  const BadgeTile({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;
    final rarity = achievement.badge.rarity;
    final color = earned ? rarityColor(rarity) : AppColors.textSecondary;
    final assetPath = badgeAssetFor(achievement.badge.id);
    final label = rarityLabel(rarity);

    return Opacity(
      opacity: earned ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: earned
              ? rarityColor(rarity).withValues(alpha: 0.09)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: earned ? rarityColor(rarity) : AppColors.outline,
            width: earned && rarity != BadgeRarity.standard ? 1.5 : 1.0,
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
                  Icon(Icons.check_circle, size: 18, color: color)
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
            if (label != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _RarityChip(label: label, color: rarityColor(rarity)),
            ],
            if (!earned) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.outline,
                  color: rarityColor(rarity),
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

class _RarityChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RarityChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
