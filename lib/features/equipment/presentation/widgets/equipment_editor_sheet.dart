import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../../design_system/widgets/section_label.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../../domain/equipment.dart';
import '../../domain/equipment_type.dart';
import '../providers/equipment_controller.dart';

/// Shows the add/edit equipment sheet. Returns the saved name on success (so a
/// caller like the log-form picker can auto-select it), or null if cancelled.
Future<String?> showEquipmentEditor(
  BuildContext context, {
  Equipment? existing,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      // Lift the sheet above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _EquipmentEditorSheet(existing: existing),
    ),
  );
}

/// One sheet reused for both adding and editing equipment (CLAUDE.md §3).
class _EquipmentEditorSheet extends ConsumerStatefulWidget {
  final Equipment? existing;

  const _EquipmentEditorSheet({this.existing});

  @override
  ConsumerState<_EquipmentEditorSheet> createState() =>
      _EquipmentEditorSheetState();
}

class _EquipmentEditorSheetState extends ConsumerState<_EquipmentEditorSheet> {
  late final TextEditingController _nameController;
  late EquipmentType _type;

  bool get _isEdit => widget.existing != null;
  bool get _isValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.type ?? EquipmentType.racket;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref.read(equipmentControllerProvider.notifier).save(
          existing: widget.existing,
          name: _nameController.text,
          type: _type,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(_nameController.text.trim());
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text("Couldn't save — please try again")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(equipmentControllerProvider).isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? 'Edit equipment' : 'Add equipment',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Name'),
            TextField(
              controller: _nameController,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Babolat Pure Aero',
              ),
              onChanged: (_) => setState(() {}), // refresh save-button enabled
              onSubmitted: (_) => _isValid && !saving ? _save() : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Type'),
            SelectableChipGroup<EquipmentType>(
              selected: _type,
              allowDeselect: false,
              options: [
                for (final t in EquipmentType.values)
                  ChipOption(value: t, label: t.label),
              ],
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: _isEdit ? 'Save' : 'Add',
              icon: Icons.check,
              isLoading: saving,
              onPressed: (_isValid && !saving) ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
