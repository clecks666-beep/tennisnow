import 'equipment_type.dart';

/// A piece of the player's gear. Pure domain entity carrying the sync-ready
/// invariant (id/createdAt/updatedAt/deletedAt) from do-not-break rule #3.
///
/// Stringing fields ([stringName], [tensionKg], [lastStrungAt]) are optional and
/// only meaningful for rackets — they capture the current setup: which string,
/// the tension in kg, and when it was last strung.
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;

  final String? stringName;
  final double? tensionKg;
  final DateTime? lastStrungAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.stringName,
    this.tensionKg,
    this.lastStrungAt,
    this.deletedAt,
  });

  bool get isArchived => deletedAt != null;

  /// True when any stringing detail has been recorded.
  bool get hasStringing =>
      stringName != null || tensionKg != null || lastStrungAt != null;

  /// Whole days since the racket was last strung, or null if unknown.
  int? daysSinceStrung({DateTime? now}) {
    if (lastStrungAt == null) return null;
    final ref = now ?? DateTime.now();
    final from = DateTime(lastStrungAt!.year, lastStrungAt!.month, lastStrungAt!.day);
    final to = DateTime(ref.year, ref.month, ref.day);
    return to.difference(from).inDays;
  }

  /// Note: copyWith cannot clear a field to null — the editor builds the entity
  /// explicitly when stringing must be cleared. Used here for non-null updates.
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
      stringName: stringName,
      tensionKg: tensionKg,
      lastStrungAt: lastStrungAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
