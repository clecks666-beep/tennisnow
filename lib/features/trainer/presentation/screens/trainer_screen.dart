import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../domain/student.dart';
import '../providers/trainer_providers.dart';
import '../widgets/add_student_sheet.dart';

/// Root trainer tab: list of active students. Trainer mode must be enabled
/// in Settings before this tab appears.
class TrainerScreen extends ConsumerWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(activeStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_student_fab',
        onPressed: () => AddStudentSheet.show(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add student'),
      ),
      body: AsyncValueView<List<Student>>(
        value: students,
        onRetry: () => ref.invalidate(activeStudentsProvider),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: 'Add your first student',
              message:
                  'Track training notes, goals and skill assessments for each '
                  'player you coach.',
              actionLabel: 'Add student',
              onAction: () => AddStudentSheet.show(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.screen,
              100,
            ),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _StudentTile(student: list[i]),
          );
        },
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(student.name, style: AppTextStyles.body),
        subtitle: Text(
          student.category.label +
              (student.birthYear != null ? '  ·  ${student.birthYear}' : ''),
          style: AppTextStyles.caption,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/trainer/student/${student.id}'),
      ),
    );
  }
}
