import 'equipment.dart';

/// Domain contract for equipment persistence. The UI depends on this interface
/// only — never on Drift (CLAUDE.md §2 dependency rule).
abstract interface class EquipmentRepository {
  /// Live list of non-archived equipment, alphabetical.
  Stream<List<Equipment>> watchActive();

  /// Creates or updates a piece of equipment (rename / change type).
  Future<void> save(Equipment equipment);

  /// Archives by id (soft-delete) so it disappears from pickers but stays
  /// sync-safe and recoverable via [restore] (do-not-break rule #3).
  Future<void> archive(String id);

  /// Reverses an archive — powers undo.
  Future<void> restore(String id);
}
