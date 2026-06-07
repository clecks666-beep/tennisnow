import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/app_progress_bar.dart';
import '../../domain/gamification_snapshot.dart';
import 'badge_visuals.dart';

/// "Next badge" — the closest unearned achievement with a goal-gradient bar, plus
/// the earned count. A public, self-contained gamification design surface (§5:
/// progression visuals are reusable, never one-off) so the Player Profile can
/// compose it without reaching into gamification internals (§2 cross-feature
/// rule). Tapping routes to the full Achievements grid via [onSeeAll].
///
/// Felt progression lives here (§4): the player always sees the single most
/// reachable trophy and exactly how close they are — honest, never nagging.
class NextBadgeCard extends StatelessWidget {
  final GamificationSnapshot snapshot;
  final VoidCallback? onSeeAll;

  const NextBadgeCard({super.key, required this.snapshot, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final next = snapshot.nextUp;
    final total = snapshot.achievements.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSeeAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: next == null
              ? _AllEarned(earned: snapshot.earnedCount, total: total)
              : _NextUp(
                  achievement: next,
                  earned: snapshot.earnedCount,
                  total: total,
                  showChevron: onSeeAll != null,
                ),
        ),
      ),
    );
  }
}

class _NextUp extends StatelessWidget {
  final Achievement achievement;
  final int earned;
  final int total;
  final bool showChevron;

  const _NextUp({
    required this.achievement,
    required this.earned,
    required this.total,
    required this.showChevron,
  });

  @override
  Widget build(BuildContext context) {
    final badge = achievement.badge;
    final remaining =
        (badge.threshold - achievement.currentValue).clamp(0, badge.threshold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _BadgeMedallion(badgeId: badge.id),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Next badge', style: AppTextStyles.caption),
                      const Spacer(),
                      Text('$earned/$total earned',
                          style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(badge.title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(badge.description, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(value: achievement.progress),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${achievement.currentValue} / ${badge.threshold} · '
          '$remaining to go',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// Celebratory, honest end-state once every badge is earned.
class _AllEarned extends StatelessWidget {
  final int earned;
  final int total;

  const _AllEarned({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: AppColors.textOnPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All badges earned', style: AppTextStyles.titleMedium),
              const SizedBox(height: 2),
              Text('$earned/$total — every milestone unlocked. Respect.',
                  style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

/// Outlined circular badge preview, mirroring the strip's medallion styling so
/// badges read identically everywhere (§5 consistency).
class _BadgeMedallion extends StatelessWidget {
  final String badgeId;

  const _BadgeMedallion({required this.badgeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline),
      ),
      child: Icon(badgeIconFor(badgeId), color: AppColors.textSecondary),
    );
  }
}
