import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_text_styles.dart';
import '../../../../design_system/widgets/selectable_chip_group.dart';
import '../providers/equipment_providers.dart';
import 'equipment_editor_sheet.dart';

/// Equipment selector for the log form. Public surface composed by
/// session_logging (CLAUDE.md §2 allows composing another feature's public
/// widgets). Pick a saved item or add one inline — optional, so it never blocks
/// the sacred fast-log path (CLAUDE.md §4).
///
/// [value] / [onChanged] carry the selected equipment NAME (stored denormalized
/// on the session). Supplementary on an already-stateful form, so while its
/// (fast, local) list loads it renders nothing rather than a spinner.
class EquipmentPickerField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const EquipmentPickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Future<void> _addNew(BuildContext context) async {
    final name = await showEquipmentEditor(context);
    if (name != null) onChanged(name); // auto-select the just-added item
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipment = ref.watch(activeEquipmentProvider);

    return equipment.maybeWhen(
      data: (list) {
        if (list.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addNew(context),
              icon: const Icon(Icons.add),
              label: const Text('Add equipment'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableChipGroup<String>(
              selected: value,
              options: [
                for (final item in list)
                  ChipOption(value: item.name, label: item.name),
              ],
              onChanged: onChanged,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addNew(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
              ),
            ),
          ],
        );
      },
      orElse: () => Text(
        'Loading equipment…',
        style: AppTextStyles.caption,
      ),
    );
  }
}
