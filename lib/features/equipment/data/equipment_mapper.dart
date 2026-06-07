import 'package:drift/drift.dart';

import '../../../shared/data/app_database.dart';
import '../domain/equipment.dart';
import '../domain/equipment_type.dart';

/// Translates between the Drift row (`EquipmentItem`) and the domain entity
/// (`Equipment`), keeping persistence types out of the domain (CLAUDE.md §2).
class EquipmentMapper {
  EquipmentMapper._();

  static Equipment toDomain(EquipmentItem row) {
    return Equipment(
      id: row.id,
      name: row.name,
      type: EquipmentType.fromStorage(row.type),
      stringName: row.stringName,
      tensionKg: row.tensionKg,
      lastStrungAt: row.lastStrungAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static EquipmentItemsCompanion toCompanion(Equipment equipment) {
    return EquipmentItemsCompanion(
      id: Value(equipment.id),
      name: Value(equipment.name),
      type: Value(equipment.type.storageValue),
      stringName: Value(equipment.stringName),
      tensionKg: Value(equipment.tensionKg),
      lastStrungAt: Value(equipment.lastStrungAt),
      createdAt: Value(equipment.createdAt),
      updatedAt: Value(equipment.updatedAt),
      deletedAt: Value(equipment.deletedAt),
    );
  }
}
