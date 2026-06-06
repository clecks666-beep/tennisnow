import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_equipment_repository.dart';
import '../../domain/equipment.dart';
import '../../domain/equipment_repository.dart';

/// Exposes the equipment repository via its domain interface (CLAUDE.md §2).
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return DriftEquipmentRepository(ref.watch(appDatabaseProvider));
});

/// Live list of the user's active (non-archived) equipment. Public surface that
/// other features may compose (e.g. the log form's picker).
final activeEquipmentProvider = StreamProvider<List<Equipment>>((ref) {
  return ref.watch(equipmentRepositoryProvider).watchActive();
});
