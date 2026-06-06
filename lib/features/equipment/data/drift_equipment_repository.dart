import '../../../shared/data/app_database.dart';
import '../domain/equipment.dart';
import '../domain/equipment_repository.dart';
import 'equipment_mapper.dart';

/// Drift-backed [EquipmentRepository]. The only place that knows about the
/// database for equipment; the rest of the app uses the interface (CLAUDE.md §2).
class DriftEquipmentRepository implements EquipmentRepository {
  final AppDatabase _db;

  DriftEquipmentRepository(this._db);

  @override
  Stream<List<Equipment>> watchActive() {
    return _db.watchActiveEquipment().map(
          (rows) => rows.map(EquipmentMapper.toDomain).toList(),
        );
  }

  @override
  Future<void> save(Equipment equipment) {
    return _db.upsertEquipment(EquipmentMapper.toCompanion(equipment));
  }

  @override
  Future<void> archive(String id) {
    return _db.setEquipmentDeletedAt(id, DateTime.now(), DateTime.now());
  }

  @override
  Future<void> restore(String id) {
    return _db.setEquipmentDeletedAt(id, null, DateTime.now());
  }
}
