import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../shared/domain/skill/skill_catalog.dart';
import '../../../../shared/domain/skill/skill_score.dart';
import '../providers/skill_rating_providers.dart';

/// Compact "Your skills" view of recency-weighted self-ratings — the payoff of
/// skill capture and the seed of the Player Profile radar. Public surface
/// composed by Progress. Supplementary, so it stays quiet while loading.
class SkillsSummary extends ConsumerWidget {
  /// How many top skills to show inline.
  final int max;

  const SkillsSummary({super.key, this.max = 6});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(skillScoresProvider);

    return scoresAsync.maybeWhen(
      data: (scores) => _content(scores),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _content(List<SkillScore> scores) {
    if (scores.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Tag the skills you work on when logging — your serve, backhand, '
            'spin and more will start leveling up here.',
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    final shown = scores.take(max).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            for (final score in shown) _SkillBar(score: score),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final SkillScore score;

  const _SkillBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final name = SkillCatalog.byId(score.skillId)?.name ?? score.skillId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              name,
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
          Text(
            score.value.toStringAsFixed(1),
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
