import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/app_progress_bar.dart';
import '../../domain/quest.dart';
import '../providers/quest_providers.dart';

/// The "This week" quests section for the Progress tab — short, optional weekly
/// goals that give the player a fresh reason to come back (★C). Self-contained
/// and reactive: it handles its own loading / error / success states (do-not-
/// break #7) so it can drop into any screen.
///
/// Felt progression lives right here (§4): each quest shows a goal-gradient bar,
/// and a completed quest flips to an on-brand "done" state the moment it's
/// earned — no nagging, no extra notifications.
class WeeklyQuestsCard extends ConsumerWidget {
  const WeeklyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(questBoardProvider);

    return boardAsync.when(
      loading: () => const _QuestsShell(child: _QuestsLoading()),
      error: (_, __) => _QuestsShell(
        child: _QuestsError(
          onRetry: () => ref.invalidate(questBoardProvider),
        ),
      ),
      data: (board) => _QuestsShell(child: _QuestsContent(board: board)),
    );
  }
}

/// Shared card chrome so every state looks identical.
class _QuestsShell extends StatelessWidget {
  final Widget child;
  const _QuestsShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

class _QuestsContent extends StatelessWidget {
  final WeeklyQuestBoard board;
  const _QuestsContent({required this.board});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text("This week's quests", style: AppTextStyles.titleMedium),
            const Spacer(),
            _CompletedPill(done: board.completedCount, total: board.total),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          board.allComplete
              ? 'All done — nice week. Fresh quests land Monday.'
              : 'Optional goals to focus your week. They reset every Monday.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < board.items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _QuestRow(progress: board.items[i]),
        ],
      ],
    );
  }
}

class _QuestRow extends StatelessWidget {
  final QuestProgress progress;
  const _QuestRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final done = progress.isComplete;
    final accent = done ? AppColors.primary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _QuestIcon(metric: progress.quest.metric, done: done),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(progress.quest.title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    progress.quest.description,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (done)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22)
            else
              Text(
                '${progress.current}/${progress.target}',
                style: AppTextStyles.label.copyWith(color: accent),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(
          value: progress.fraction,
          color: done ? AppColors.primary : AppColors.accent,
        ),
        if (!done) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            progress.remaining == 1
                ? '1 to go'
                : '${progress.remaining} to go',
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

class _QuestIcon extends StatelessWidget {
  final QuestMetric metric;
  final bool done;
  const _QuestIcon({required this.metric, required this.done});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : AppColors.textSecondary;
    return Container(
      height: 36,
      width: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (done ? AppColors.primary : AppColors.textSecondary)
            .withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(_iconFor(metric), color: color, size: 20),
    );
  }

  static IconData _iconFor(QuestMetric metric) {
    switch (metric) {
      case QuestMetric.sessionsThisWeek:
        return Icons.event_repeat_rounded;
      case QuestMetric.skillFocusThisWeek:
        return Icons.center_focus_strong_rounded;
      case QuestMetric.feelingSessionsThisWeek:
        return Icons.favorite_rounded;
    }
  }
}

class _CompletedPill extends StatelessWidget {
  final int done;
  final int total;
  const _CompletedPill({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final allDone = total > 0 && done == total;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: allDone
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '$done/$total',
        style: AppTextStyles.caption.copyWith(
          color: allDone ? AppColors.textOnPrimary : AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _QuestsLoading extends StatelessWidget {
  const _QuestsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('Loading your quests…', style: AppTextStyles.caption),
      ],
    );
  }
}

class _QuestsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _QuestsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Couldn't load this week's quests.",
            style: AppTextStyles.caption,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
