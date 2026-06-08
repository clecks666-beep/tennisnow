import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../domain/student.dart';
import '../providers/trainer_providers.dart';

/// Bottom sheet for adding a new student.
class AddStudentSheet extends StatefulWidget {
  final WidgetRef ref;
  const AddStudentSheet._({required this.ref});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddStudentSheet._(ref: ref),
    );
  }

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  StudentCategory _category = StudentCategory.adult;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final birthYear = int.tryParse(_birthYearController.text.trim());
    final student = Student(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      birthYear: birthYear,
      category: _category,
      createdAt: now,
      updatedAt: now,
    );
    await widget.ref.read(trainerRepositoryProvider).saveStudent(student);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, bottom + AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New student', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                  labelText: 'Birth year (optional)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final y = int.tryParse(v.trim());
                if (y == null || y < 1920 || y > DateTime.now().year) {
                  return 'Enter a valid year';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Category', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            SelectableChipGroup<StudentCategory>(
              selected: _category,
              allowDeselect: false,
              options: StudentCategory.values
                  .map((c) => ChipOption(value: c, label: c.label))
                  .toList(),
              onChanged: (c) {
                if (c != null) setState(() => _category = c);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add student'),
            ),
          ],
        ),
      ),
    );
  }
}
