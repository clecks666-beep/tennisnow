import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../domain/training_note.dart';
import '../providers/trainer_providers.dart';

/// Bottom sheet for adding a coaching note to a student.
class AddNoteSheet extends StatefulWidget {
  final WidgetRef ref;
  final String studentId;
  const AddNoteSheet._({required this.ref, required this.studentId});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String studentId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          AddNoteSheet._(ref: ref, studentId: studentId),
    );
  }

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  NoteType _type = NoteType.observation;
  DateTime _sessionDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _sessionDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final note = TrainingNote(
      id: const Uuid().v4(),
      studentId: widget.studentId,
      type: _type,
      content: _contentController.text.trim(),
      sessionDate: _sessionDate,
      createdAt: now,
      updatedAt: now,
    );
    await widget.ref.read(trainerRepositoryProvider).saveNote(note);
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
            Text('New note', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Text('Type', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            SelectableChipGroup<NoteType>(
              selected: _type,
              allowDeselect: false,
              options: NoteType.values
                  .map((t) => ChipOption(value: t, label: t.label))
                  .toList(),
              onChanged: (t) {
                if (t != null) setState(() => _type = t);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Session date',
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(_formatDate(_sessionDate)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note *',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Note content is required' : null,
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
                  : const Text('Save note'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
