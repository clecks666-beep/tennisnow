import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/coach_insight.dart';
import '../providers/coach_providers.dart';

/// The coach's read on the player's game: one honest headline, a forward-looking
/// note, and the signals it's based on (explainability, CLAUDE.md §11). Composes
/// only design-system tokens (§5) and the coach's public provider. The source
/// tag is shown honestly — a real model is labelled, the deterministic coach
/// isn't dressed up as AI (§7/§11).
class CoachCard extends ConsumerWidget {
  const CoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(coachInsightProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Your coach',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                _SourceTag(source: insight.source),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(insight.headline, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              insight.body,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            if (insight.basis.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final b in insight.basis) _BasisChip(label: b),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Honest provenance label: only a live model earns the "AI" badge; the
/// deterministic coach shows nothing (never faked as AI).
class _SourceTag extends StatelessWidget {
  final CoachSource source;

  const _SourceTag({required this.source});

  @override
  Widget build(BuildContext context) {
    if (source != CoachSource.ai) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        'AI',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A small explainability pill naming one signal the read is grounded in.
class _BasisChip extends StatelessWidget {
  final String label;

  const _BasisChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}
