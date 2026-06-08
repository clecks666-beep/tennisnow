import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../domain/student.dart';
import '../../domain/training_note.dart';
import '../providers/trainer_providers.dart';
import '../widgets/add_note_sheet.dart';

/// Detail screen for a single student: notes log, future goals & assessments.
class StudentProfileScreen extends ConsumerWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(trainerRepositoryProvider);
    final notesAsync = ref.watch(notesForStudentProvider(studentId));

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
            heroTag: 'add_note_fab',
            onPressed: () =>
                AddNoteSheet.show(context, ref, studentId: studentId),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add note'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (student != null) _StudentHeader(student: student),
              Expanded(
                child: notesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: FilledButton.tonal(
                      onPressed: () =>
                          ref.invalidate(notesForStudentProvider(studentId)),
                      child: const Text('Try again'),
                    ),
                  ),
                  data: (notes) {
                    if (notes.isEmpty) {
                      return EmptyState(
                        icon: Icons.sticky_note_2_outlined,
                        title: 'No notes yet',
                        message:
                            'Add observations, homework, or technique notes '
                            'after each session.',
                        actionLabel: 'Add note',
                        onAction: () => AddNoteSheet.show(context, ref,
                            studentId: studentId),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.md,
                        AppSpacing.screen,
                        100,
                      ),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) =>
                          _NoteTile(note: notes[i], ref: ref),
                    );
                  },
                ),
              ),
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
              'notes and goals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error),
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

class _StudentHeader extends StatelessWidget {
  final Student student;
  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.06),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.primary),
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

class _NoteTile extends StatelessWidget {
  final TrainingNote note;
  final WidgetRef ref;
  const _NoteTile({required this.note, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        final repo = ref.read(trainerRepositoryProvider);
        await repo.deleteNote(note.id, DateTime.now());
        return false; // stream removes it reactively
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeChip(type: note.type),
                  const Spacer(),
                  Text(
                    _formatDate(note.sessionDate),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(note.content, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _TypeChip extends StatelessWidget {
  final NoteType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
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
