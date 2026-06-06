import 'package:flutter/material.dart';

import '../../domain/equipment_type.dart';

/// Maps an equipment type to its icon. Presentation-only, so the domain stays
/// Flutter-free (CLAUDE.md §2).
IconData equipmentIconFor(EquipmentType type) {
  switch (type) {
    case EquipmentType.racket:
      return Icons.sports_tennis_rounded;
    case EquipmentType.strings:
      return Icons.timeline_rounded;
    case EquipmentType.shoes:
      return Icons.directions_run_rounded;
    case EquipmentType.other:
      return Icons.backpack_outlined;
  }
}
