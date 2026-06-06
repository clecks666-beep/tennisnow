import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../../../design_system/widgets/mini_line_chart.dart';
import '../../../../design_system/widgets/stat_card.dart';
import '../../domain/progress_insight.dart';
import '../../domain/session_stats.dart';
import '../../domain/trend_point.dart';
import '../providers/progress_providers.dart';

/// Progress tab: turns logged sessions into motivating, honest trends.
/// Handles loading / empty / error / success (do-not-break rule #5).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sessionStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: AsyncValueView<SessionStats>(
        value: statsAsync,
        onRetry: () => ref.invalidate(sessionStatsProvider),
        data: (stats) {
          if (stats.isEmpty) {
            return const EmptyState(
              icon: Icons.insights_rounded,
              title: 'No trends yet',
              message:
                  'Log a few sessions — including how you played and felt — '
                  'and your progress will show up here.',
            );
          }
          return _ProgressContent(stats: stats);
        },
      ),
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  final SessionStats stats;

  const _ProgressContent({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(performanceTrendProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        _InsightBanner(text: ProgressInsight.headline(stats)),
        const SizedBox(height: AppSpacing.lg),

        _StatsGrid(stats: stats),
        const SizedBox(height: AppSpacing.lg),

        Text('Performance trend', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        // Trend has its own async state nested under the loaded stats.
        AsyncValueView<List<TrendPoint>>(
          value: trendAsync,
          onRetry: () => ref.invalidate(performanceTrendProvider),
          data: (points) => _TrendSection(points: points),
        ),
      ],
    );
  }
}

class _InsightBanner extends StatelessWidget {
  final String text;

  const _InsightBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.emoji_objects_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final SessionStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final winRate = stats.winRate;
    final cards = <Widget>[
      StatCard(
        label: 'Sessions',
        value: '${stats.totalSessions}',
        icon: Icons.sports_tennis_outlined,
        caption: stats.matchCount > 0 ? '${stats.matchCount} matches' : null,
      ),
      StatCard(
        label: 'Win rate',
        value: winRate == null ? null : '${(winRate * 100).round()}%',
        icon: Icons.emoji_events_outlined,
        caption: winRate == null
            ? 'Log match results'
            : '${stats.winCount}/${stats.ratedMatchCount} won',
      ),
      StatCard(
        label: 'Avg performance',
        value: _fmt(stats.avgPerformance),
        icon: Icons.trending_up_rounded,
        caption: 'out of 5',
      ),
      StatCard(
        label: 'Avg mood',
        value: _fmt(stats.avgMood),
        icon: Icons.sentiment_satisfied_rounded,
        caption: 'out of 5',
      ),
      StatCard(
        label: 'Avg energy',
        value: _fmt(stats.avgEnergy),
        icon: Icons.bolt_outlined,
        caption: 'out of 5',
      ),
    ];

    // Responsive two-column grid that adapts to width without overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(width: itemWidth, child: card),
          ],
        );
      },
    );
  }

  static String? _fmt(double? value) =>
      value == null ? null : value.toStringAsFixed(1);
}

class _TrendSection extends StatelessWidget {
  final List<TrendPoint> points;

  const _TrendSection({required this.points});

  @override
  Widget build(BuildContext context) {
    // Need at least two points to draw a meaningful line.
    if (points.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Rate your performance on at least two sessions to see your trend.',
            style: AppTextStyles.caption,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MiniLineChart(
              values: points.map((p) => p.performance.toDouble()).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Last ${points.length} rated sessions (oldest → newest)',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
