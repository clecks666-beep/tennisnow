import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../../../design_system/widgets/skill_radar_chart.dart';
import '../../../../shared/domain/skill/skill_score.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../gamification/presentation/widgets/player_level_card.dart';
import '../../../skills/presentation/providers/skill_rating_providers.dart';
import '../../../skills/presentation/widgets/skills_summary.dart';
import '../../domain/category_score.dart';
import '../../domain/player_profile_builder.dart';

/// The Player Profile — the gamified centrepiece (★ section): the player's real
/// tennis skills, visualised as a radar of categories on top of their level/XP.
///
/// Pushed above the shell (a detail screen). Composes other features' PUBLIC
/// surfaces only — gamification's level card + provider and the skills feature's
/// scores provider/summary — never their internals (CLAUDE.md §2 cross-feature
/// rule). Handles loading/empty/error/success (do-not-break rule #5).
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(skillScoresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: AsyncValueView<List<SkillScore>>(
        value: scoresAsync,
        onRetry: () => ref.invalidate(skillScoresProvider),
        data: (scores) {
          if (scores.isEmpty) {
            return EmptyState(
              icon: Icons.radar_rounded,
              title: 'Your game starts here',
              message:
                  'Log a session and tag the skills you worked on — your serve, '
                  'backhand, spin and more will start leveling up on your profile.',
              actionLabel: 'Log a session',
              onAction: () => context.push('/log'),
            );
          }
          return _ProfileContent(scores: scores);
        },
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final List<SkillScore> scores;

  const _ProfileContent({required this.scores});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = PlayerProfileBuilder.categoryScores(scores);
    final overall = PlayerProfileBuilder.overall(categories);
    final levelAsync = ref.watch(gamificationProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        // Level/XP headline — supplementary here, so it stays quiet until ready.
        levelAsync.maybeWhen(
          data: (snapshot) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: PlayerLevelCard(level: snapshot.level),
          ),
          orElse: () => const SizedBox.shrink(),
        ),

        _RadarCard(categories: categories, overall: overall),
        const SizedBox(height: AppSpacing.lg),

        Text('Categories', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _CategoryBreakdown(categories: categories),
        const SizedBox(height: AppSpacing.lg),

        Text('Top skills', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const SkillsSummary(),
      ],
    );
  }
}

/// The radar centrepiece with an honest overall-strength headline.
class _RadarCard extends StatelessWidget {
  final List<CategoryScore> categories;
  final double overall;

  const _RadarCard({required this.categories, required this.overall});

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final c in categories)
        RadarEntry(label: c.category.label, value: c.fraction),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  overall <= 0 ? '—' : overall.toStringAsFixed(1),
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 32),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('/ 5 overall', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              // Inset so the axis labels have room inside the card.
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SkillRadarChart(entries: entries),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CategoryScore> categories;

  const _CategoryBreakdown({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            for (final c in categories) _CategoryRow(score: c),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryScore score;

  const _CategoryRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              score.category.label,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: score.fraction,
                minHeight: 6,
                backgroundColor: AppColors.outline,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 28,
            child: Text(
              score.hasData ? score.value.toStringAsFixed(1) : '—',
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
