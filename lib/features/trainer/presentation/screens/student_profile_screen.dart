import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../../../design_system/widgets/mini_line_chart.dart';
import '../../../../design_system/widgets/stat_card.dart';
import '../../../../shared/domain/skill/skill_catalog.dart';
import '../../../../shared/domain/skill/skill_score.dart';
import '../../domain/student.dart';
import '../../domain/student_session.dart';
import '../../domain/student_stats.dart';
import '../../domain/training_note.dart';
import '../providers/trainer_providers.dart';
import '../widgets/add_note_sheet.dart';

/// Expanded student profile: stats overview, session history, skills and notes.
/// Mirrors the Progress tab for coached players — the trainer has the full picture.
class StudentProfileScreen extends ConsumerWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(trainerRepositoryProvider);
    final notesAsync = ref.watch(notesForStudentProvider(studentId));
    final sessionsAsync = ref.watch(studentSessionsProvider(studentId));
    final statsAsync = ref.watch(studentStatsProvider(studentId));
    final trendAsync = ref.watch(studentPerformanceTrendProvider(studentId));
    final skillsAsync = ref.watch(studentSkillScoresProvider(studentId));

    return FutureBuilder<Student?>(
      future: repo.studentById(studentId),
      builder: (context, snap) {
        final student = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(student?.name ?? 'Student'),
            actions: [
              if (student != null)
                PopupMenuButton<_Action>(
                  onSelected: (action) =>
                      _handleAction(context, ref, student, action),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: _Action.archive,
                      child: Text('Archive student'),
                    ),
                    const PopupMenuItem(
                      value: _Action.delete,
                      child: Text('Delete student'),
                    ),
                  ],
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'log_session_fab',
            onPressed: () => context.push('/trainer/student/$studentId/log'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log session'),
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (student != null) _StudentHeader(student: student),

              statsAsync.when(
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _StatsSection(stats: stats),
              ),

              trendAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (points) => _TrendSection(points: points),
              ),

              skillsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (scores) => _SkillsSection(scores: scores),
              ),

              _SectionHeader(
                title: 'Sessions',
                count: sessionsAsync.valueOrNull?.length,
              ),
              sessionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: FilledButton.tonal(
                    onPressed: () =>
                        ref.invalidate(studentSessionsProvider(studentId)),
                    child: const Text('Try again'),
                  ),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                          AppSpacing.screen, AppSpacing.md),
                      child: EmptyState(
                        icon: Icons.sports_tennis_outlined,
                        title: 'No sessions yet',
                        message:
                            'Tap "Log session" to record the first session with '
                            '${student?.name ?? 'this student'}.',
                        actionLabel: 'Log session',
                        onAction: () =>
                            context.push('/trainer/student/$studentId/log'),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final s in sessions)
                        _SessionTile(
                          session: s,
                          studentId: studentId,
                          onDelete: () => ref
                              .read(trainerRepositoryProvider)
                              .deleteStudentSession(s.id, DateTime.now()),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  );
                },
              ),

              _SectionHeader(
                title: 'Notes',
                count: notesAsync.valueOrNull?.length,
                action: TextButton.icon(
                  onPressed: () =>
                      AddNoteSheet.show(context, ref, studentId: studentId),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ),
              notesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (notes) {
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                          AppSpacing.screen, AppSpacing.md),
                      child: Text(
                        'No notes yet — add observations, homework or technique notes.',
                        style: AppTextStyles.caption,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final n in notes) _NoteTile(note: n, ref: ref),
                    ],
                  );
                },
              ),

              const SizedBox(height: 100), // FAB clearance
            ],
          ),
        );
      },
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    Student student,
    _Action action,
  ) async {
    final repo = ref.read(trainerRepositoryProvider);
    final now = DateTime.now();
    switch (action) {
      case _Action.archive:
        await repo.archiveStudent(student.id, now);
        if (context.mounted) Navigator.of(context).pop();
        break;
      case _Action.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete student?'),
            content: Text(
              'This will permanently remove ${student.name} and all their '
              'sessions, notes and goals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.deleteStudent(student.id, now);
          if (context.mounted) Navigator.of(context).pop();
        }
        break;
    }
  }
}

enum _Action { archive, delete }

// ── Student header ────────────────────────────────────────────────────────────

class _StudentHeader extends StatelessWidget {
  final Student student;
  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.06),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style:
                  AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.titleMedium),
                Text(
                  [
                    student.category.label,
                    if (student.birthYear != null)
                      'Born ${student.birthYear}',
                  ].join('  ·  '),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats section ─────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  final StudentStats stats;
  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final winRate = stats.winRate;
    final cards = <Widget>[
      StatCard(
        label: 'Sessions',
        value: '${stats.totalSessions}',
        icon: Icons.sports_tennis_outlined,
        caption:
            stats.matchCount > 0 ? '${stats.matchCount} matches' : null,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.md, AppSpacing.screen, 0),
      child: LayoutBuilder(
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
      ),
    );
  }

  static String? _fmt(double? v) =>
      v == null ? null : v.toStringAsFixed(1);
}

// ── Trend section ─────────────────────────────────────────────────────────────

class _TrendSection extends StatelessWidget {
  final List<StudentSession> points;
  const _TrendSection({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance trend', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MiniLineChart(
                    values: points
                        .map((p) => p.performance!.value.toDouble())
                        .toList(),
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
          ),
        ],
      ),
    );
  }
}

// ── Skills section ────────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  final List<SkillScore> scores;
  const _SkillsSection({required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();
    final top = scores.take(6).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  for (int i = 0; i < top.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    _SkillRow(score: top[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillScore score;
  const _SkillRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final label = SkillCatalog.byId(score.skillId)?.name ?? score.skillId;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: LinearProgressIndicator(
              value: score.fraction,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 28,
          child: Text(
            score.value.toStringAsFixed(1),
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? action;
  const _SectionHeader({required this.title, this.count, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xs),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          if (count != null && count! > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ── Session tile ──────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final StudentSession session;
  final String studentId;
  final VoidCallback onDelete;
  const _SessionTile(
      {required this.session,
      required this.studentId,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen, vertical: 2),
      child: Dismissible(
        key: ValueKey(session.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: () => context.push(
              '/trainer/student/$studentId/log',
              extra: session,
            ),
            leading: Icon(
              session.isMatch
                  ? Icons.emoji_events_outlined
                  : Icons.sports_tennis_outlined,
              color: AppColors.primary,
            ),
            title: Row(
              children: [
                Text(session.type.label, style: AppTextStyles.body),
                if (session.result != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _ResultChip(label: session.result!.label),
                ],
              ],
            ),
            subtitle: Text(_fmtDate(session.playedAt),
                style: AppTextStyles.caption),
            trailing: session.performance != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${session.performance!.value}/5',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textPrimary)),
                      Text('perf', style: AppTextStyles.caption),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _ResultChip extends StatelessWidget {
  final String label;
  const _ResultChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Note tile ─────────────────────────────────────────────────────────────────

class _NoteTile extends StatelessWidget {
  final TrainingNote note;
  final WidgetRef ref;
  const _NoteTile({required this.note, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen, vertical: 2),
      child: Dismissible(
        key: ValueKey(note.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
        confirmDismiss: (_) async {
          await ref
              .read(trainerRepositoryProvider)
              .deleteNote(note.id, DateTime.now());
          return false;
        },
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeChip(type: note.type),
                    const Spacer(),
                    Text(_fmtDate(note.sessionDate),
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(note.content, style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _TypeChip extends StatelessWidget {
  final NoteType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.caption
            .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
