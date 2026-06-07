import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../shared/domain/progression/player_level.dart';

/// The player level headline — the start of the Player Profile (★ section):
/// level badge + title, total XP, and an XP progress bar to the next level.
///
/// Public, self-contained design surface: composed by the Progress strip and the
/// Player Profile screen (CLAUDE.md §5 — progression visuals are reusable, never
/// one-off per screen). Optionally tappable to open the full profile.
class PlayerLevelCard extends StatelessWidget {
  final PlayerLevel level;
  final VoidCallback? onTap;

  const PlayerLevelCard({super.key, required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _LevelBadge(level: level.level),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${level.level} · ${level.title}',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 2),
                        Text('${level.totalXp} XP total',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${level.xpToNextLevel} XP to level ${level.level + 1}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        '$level',
        style:
            AppTextStyles.titleMedium.copyWith(color: AppColors.textOnPrimary),
      ),
    );
  }
}
