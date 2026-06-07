import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// Stringing fields (string, tension, last strung) appear only for rackets.
class _EquipmentEditorSheet extends ConsumerStatefulWidget {
  final Equipment? existing;

  const _EquipmentEditorSheet({this.existing});

  @override
  ConsumerState<_EquipmentEditorSheet> createState() =>
      _EquipmentEditorSheetState();
}

class _EquipmentEditorSheetState extends ConsumerState<_EquipmentEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _stringController;
  late final TextEditingController _tensionController;
  late EquipmentType _type;
  DateTime? _lastStrungAt;

  bool get _isEdit => widget.existing != null;
  bool get _isValid => _nameController.text.trim().isNotEmpty;
  bool get _showStringing => _type == EquipmentType.racket;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _stringController = TextEditingController(text: e?.stringName ?? '');
    _tensionController = TextEditingController(
      text: e?.tensionKg == null ? '' : _formatKg(e!.tensionKg!),
    );
    _type = e?.type ?? EquipmentType.racket;
    _lastStrungAt = e?.lastStrungAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stringController.dispose();
    _tensionController.dispose();
    super.dispose();
  }

  static String _formatKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);

  String? _trimToNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  double? _parseTension() {
    final raw = _tensionController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _pickStrungDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastStrungAt ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) setState(() => _lastStrungAt = picked);
  }

  Future<void> _save() async {
    final ok = await ref.read(equipmentControllerProvider.notifier).save(
          existing: widget.existing,
          name: _nameController.text,
          type: _type,
          // Stringing only applies to rackets; cleared otherwise.
          stringName: _showStringing ? _trimToNull(_stringController.text) : null,
          tensionKg: _showStringing ? _parseTension() : null,
          lastStrungAt: _showStringing ? _lastStrungAt : null,
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
      child: SingleChildScrollView(
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

            // ---- Stringing (rackets only) ----
            if (_showStringing) ...[
              const SizedBox(height: AppSpacing.lg),
              const SectionLabel('Stringing', optional: true),
              TextField(
                controller: _stringController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'String',
                  hintText: 'e.g. Luxilon ALU Power',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _tensionController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tension',
                  hintText: 'e.g. 23',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StrungDateField(
                date: _lastStrungAt,
                onPick: _pickStrungDate,
                onClear: () => setState(() => _lastStrungAt = null),
              ),
            ],

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

/// "Last strung" date row: a labelled picker button with a clear affordance.
class _StrungDateField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _StrungDateField({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? 'Last strung — set date'
        : 'Last strung: ${date!.day}.${date!.month}.${date!.year}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (date != null)
          IconButton(
            tooltip: 'Clear date',
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    );
  }
}
