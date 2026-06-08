import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/app_progress_bar.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/avatar_widget.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../../../design_system/widgets/skill_radar_chart.dart';
import '../../../../shared/data/app_preferences.dart';
import '../../../../shared/domain/avatar/avatar_config.dart';
import '../../../../shared/domain/skill/skill_score.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../gamification/presentation/widgets/next_badge_card.dart';
import '../../../gamification/presentation/widgets/player_level_card.dart';
import '../../../gamification/presentation/widgets/streak_banner.dart';
import '../../../skills/presentation/providers/skill_rating_providers.dart';
import '../../../skills/presentation/widgets/skills_summary.dart';
import '../../domain/category_score.dart';
import '../../domain/player_profile_builder.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_editor_sheet.dart';

/// The Player Profile — the gamified centrepiece (★ section): a real-tennis
/// "character sheet" where logging becomes a felt progression. Level + title as
/// the hero, the live streak, a radar of skill categories with an honest
/// "edge / work-on-next" read, the closest badge, and the player's top skills.
///
/// Pushed above the shell (a detail screen). Composes other features' PUBLIC
/// surfaces only — gamification's level card, streak banner, next-badge card +
/// provider, and the skills feature's scores provider/summary — never their
/// internals (CLAUDE.md §2 cross-feature rule). All scoring is pure domain
/// (PlayerProfileBuilder); the UI only reads it. Handles loading/empty/error/
/// success (do-not-break rule #7).
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(skillScoresProvider);
    final avatarConfig = ref.watch(avatarConfigProvider);
    final displayName = ref.watch(appPreferencesProvider).displayName;

    return Scaffold(
      appBar: AppBar(title: const Text('Player Profile')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar hero — always visible, independent of skill data.
          _AvatarHero(
            config: avatarConfig,
            displayName: displayName,
            onEdit: () => AvatarEditorSheet.show(context),
          ),
          const Divider(height: 1, color: AppColors.outline),
          Expanded(
            child: AsyncValueView<List<SkillScore>>(
              value: scoresAsync,
              onRetry: () => ref.invalidate(skillScoresProvider),
              data: (scores) {
                if (scores.isEmpty) {
                  return EmptyState(
                    imagePath:
                        'assets/images/brand/empty_states/empty_player_profile.png',
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
          ),
        ],
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
    final strongest = PlayerProfileBuilder.strongest(categories);
    final focus = PlayerProfileBuilder.focus(categories);
    final gameAsync = ref.watch(gamificationProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        // Hero: who you are right now — level, title, XP — plus the live streak.
        // Primary content on this screen, so it shows a quiet skeleton while its
        // (fast, local) data loads rather than popping in.
        gameAsync.when(
          loading: () => const _HeroSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlayerLevelCard(level: snapshot.level),
              const SizedBox(height: AppSpacing.md),
              StreakBanner(streak: snapshot.streak),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        _RadarCard(
          categories: categories,
          overall: overall,
          strongest: strongest,
          focus: focus,
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Categories', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        _CategoryBreakdown(categories: categories, strongest: strongest),
        const SizedBox(height: AppSpacing.lg),

        // The closest trophy — the next milestone to chase.
        gameAsync.maybeWhen(
          data: (snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Achievements', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              NextBadgeCard(
                snapshot: snapshot,
                onSeeAll: () => context.push('/achievements'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        ),

        Text('Top skills', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const SkillsSummary(),
      ],
    );
  }
}

/// The radar centrepiece with an honest overall-strength headline and an
/// actionable read of the player's edge and next focus.
class _RadarCard extends StatelessWidget {
  final List<CategoryScore> categories;
  final double overall;
  final CategoryScore? strongest;
  final CategoryScore? focus;

  const _RadarCard({
    required this.categories,
    required this.overall,
    required this.strongest,
    required this.focus,
  });

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
            _FocusCallout(strongest: strongest, focus: focus),
          ],
        ),
      ),
    );
  }
}

/// An honest, motivating read of the radar shape: the player's strongest area
/// ("edge") and the most rewarding place to grow next. Both are purely derived
/// (PlayerProfileBuilder) — never invented. Hidden entirely until there's a
/// signal, and the focus chip is suppressed when it would just repeat the edge.
class _FocusCallout extends StatelessWidget {
  final CategoryScore? strongest;
  final CategoryScore? focus;

  const _FocusCallout({required this.strongest, required this.focus});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (strongest != null) {
      chips.add(_ProfileChip(
        icon: Icons.trending_up_rounded,
        label: 'Edge',
        value:
            '${strongest!.category.label} · ${strongest!.value.toStringAsFixed(1)}',
        color: AppColors.primary,
        filled: true,
      ));
    }

    // Only show a focus chip when it adds new information (a different category).
    final showFocus =
        focus != null && (strongest == null || focus!.category != strongest!.category);
    if (showFocus) {
      chips.add(_ProfileChip(
        icon: Icons.center_focus_strong_rounded,
        label: 'Work on next',
        value: focus!.hasData
            ? focus!.category.label
            : '${focus!.category.label} · not started',
        color: AppColors.draw,
        filled: false,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: chips,
      ),
    );
  }
}

/// Small pill conveying a labelled fact (edge / focus). Filled for emphasis,
/// outlined for a quieter, guiding tone. A local profile primitive built from
/// design tokens only (no inline colors/sizes, §5).
class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool filled;

  const _ProfileChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.10) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: filled ? Colors.transparent : AppColors.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(value, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CategoryScore> categories;
  final CategoryScore? strongest;

  const _CategoryBreakdown({required this.categories, required this.strongest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            for (final c in categories)
              _CategoryRow(
                score: c,
                isEdge: strongest != null && c.category == strongest!.category,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryScore score;
  final bool isEdge;

  const _CategoryRow({required this.score, required this.isEdge});

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
            child: AppProgressBar(
              value: score.fraction,
              // The edge category reads in the brand colour; the rest stay quiet
              // so the strongest area is instantly scannable.
              color: isEdge ? AppColors.primary : AppColors.textSecondary,
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

// ── Avatar hero ───────────────────────────────────────────────────────────────

/// Always-visible identity section at the top of the profile — avatar + name +
/// edit affordance. Independent of skill data so there is always something
/// personal to see and customise, even before the first logged session.
class _AvatarHero extends StatelessWidget {
  final AvatarConfig config;
  final String? displayName;
  final VoidCallback onEdit;

  const _AvatarHero({
    required this.config,
    required this.displayName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen, vertical: AppSpacing.lg),
      child: Row(
        children: [
          // Avatar circle with edit badge overlay
          GestureDetector(
            onTap: onEdit,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarWidget(config: config, size: 80),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 13, color: AppColors.textOnPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName ?? 'Tennis Player',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: displayName != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Customize avatar',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quiet placeholder for the level/streak hero while its fast local data loads,
/// keeping the layout stable (no pop-in) without a heavy spinner.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _skeletonCard(96),
        const SizedBox(height: AppSpacing.md),
        _skeletonCard(72),
      ],
    );
  }

  Widget _skeletonCard(double height) {
    return Card(
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
