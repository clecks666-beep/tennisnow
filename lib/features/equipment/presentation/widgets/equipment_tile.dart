import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/equipment.dart';
import 'equipment_visuals.dart';

/// One row in the equipment list. Tapping opens the editor. For rackets with
/// stringing, shows the current setup and how long ago it was strung.
class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  /// Suggest a restring after roughly this many days (gentle, non-nagging hint).
  static const int restringHintDays = 60;

  const EquipmentTile({
    super.key,
    required this.equipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        isThreeLine: equipment.hasStringing,
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(equipmentIconFor(equipment.type), color: AppColors.primary),
        ),
        title: Text(equipment.name, style: AppTextStyles.body),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(equipment.type.label, style: AppTextStyles.caption),
            if (_stringingLine() != null)
              Text(_stringingLine()!, style: AppTextStyles.caption),
            if (_strungLine() != null) _strungLine()!,
          ],
        ),
        trailing: const Icon(Icons.edit_outlined, size: 18),
      ),
    );
  }

  String? _stringingLine() {
    final parts = <String>[];
    if (equipment.tensionKg != null) {
      parts.add('${_fmtKg(equipment.tensionKg!)} kg');
    }
    if (equipment.stringName != null) parts.add(equipment.stringName!);
    return parts.isEmpty ? null : parts.join('  ·  ');
  }

  Widget? _strungLine() {
    final days = equipment.daysSinceStrung();
    if (days == null) return null;
    final overdue = days > restringHintDays;
    final when = switch (days) {
      0 => 'strung today',
      1 => 'strung yesterday',
      _ => 'strung $days days ago',
    };
    return Text(
      overdue ? '$when · time to restring?' : when,
      style: AppTextStyles.caption.copyWith(
        color: overdue ? AppColors.draw : AppColors.textSecondary,
        fontWeight: overdue ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  static String _fmtKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
}
