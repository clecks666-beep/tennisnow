import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_text_styles.dart';
import '../../domain/equipment.dart';
import 'equipment_visuals.dart';

/// One row in the equipment list. Tapping opens the editor.
class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

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
        subtitle: Text(equipment.type.label, style: AppTextStyles.caption),
        trailing: const Icon(Icons.edit_outlined, size: 18),
      ),
    );
  }
}
