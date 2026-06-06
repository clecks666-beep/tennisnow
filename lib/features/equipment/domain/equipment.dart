import 'equipment_type.dart';

/// A piece of the player's gear. Pure domain entity carrying the sync-ready
/// invariant (id/createdAt/updatedAt/deletedAt) from do-not-break rule #3.
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isArchived => deletedAt != null;

  Equipment copyWith({
    String? name,
    EquipmentType? type,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Equipment(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
