import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/badge.dart';
import '../../domain/gamification_snapshot.dart';
import '../providers/gamification_providers.dart';
import 'badge_visuals.dart';
import 'streak_banner.dart';

/// The motivation section shown at the top of Progress: streak + a badge
/// preview with a route into the full Achievements grid.
///
/// This is supplementary to the already state-complete Progress screen, so
/// while its (fast, local) data loads or if it errors it renders nothing rather
/// than a spinner — a deliberate, documented exception to do-not-break rule #5.
class GamificationStrip extends ConsumerWidget {
  const GamificationStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(gamificationProvider);

    return snapshotAsync.maybeWhen(
      data: (snapshot) => _Strip(snapshot: snapshot),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Strip extends StatelessWidget {
  final GamificationSnapshot snapshot;

  const _Strip({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreakBanner(streak: snapshot.streak),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text('Badges', style: AppTextStyles.titleMedium),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${snapshot.earnedCount}/${snapshot.achievements.length}',
              style: AppTextStyles.caption,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/achievements'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) =>
                _Medallion(achievement: snapshot.achievements[index]),
          ),
        ),
      ],
    );
  }
}

/// Small circular badge preview used in the horizontal strip.
class _Medallion extends StatelessWidget {
  final Achievement achievement;

  const _Medallion({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earned;
    return Tooltip(
      message: '${achievement.badge.title} · ${achievement.badge.description}',
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: earned
              ? AppColors.primary.withOpacity(0.10)
              : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: earned ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Icon(
          badgeIconFor(achievement.badge.id),
          color: earned ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
