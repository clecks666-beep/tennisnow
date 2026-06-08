import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/avatar_widget.dart';
import '../../../../shared/data/app_preferences.dart';
import '../../domain/gamification_snapshot.dart';
import '../providers/gamification_providers.dart';
import '../widgets/badge_tile.dart';
import '../widgets/streak_banner.dart';
import '../../../player_profile/presentation/providers/avatar_provider.dart';

/// Full achievements view: streak + every badge with earned/locked + progress.
/// Pushed above the shell (a detail screen, not a tab). Handles
/// loading/empty/error/success via AsyncValueView (do-not-break rule #5).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: AsyncValueView<GamificationSnapshot>(
        value: snapshotAsync,
        onRetry: () => ref.invalidate(gamificationProvider),
        data: (snapshot) => _AchievementsContent(snapshot: snapshot),
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  final GamificationSnapshot snapshot;

  const _AchievementsContent({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        _PlayerHeader(snapshot: snapshot),
        const SizedBox(height: AppSpacing.md),
        StreakBanner(streak: snapshot.streak),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Badges', style: AppTextStyles.titleMedium),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${snapshot.earnedCount} of ${snapshot.achievements.length} earned',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.achievements.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) =>
              BadgeTile(achievement: snapshot.achievements[index]),
        ),
      ],
    );
  }
}

/// Compact identity row — avatar + name + level — at the top of the
/// achievements view so the screen feels personal, not generic.
class _PlayerHeader extends ConsumerWidget {
  final GamificationSnapshot snapshot;

  const _PlayerHeader({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(avatarConfigProvider);
    final name = ref.watch(appPreferencesProvider).displayName;

    return Row(
      children: [
        AvatarWidget(config: config, size: 48),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? 'Tennis Player',
                style: AppTextStyles.label.copyWith(
                  color: name != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Level ${snapshot.level.level} · ${snapshot.level.title}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
