import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/id/id_generator.dart';
import '../../domain/equipment.dart';
import '../../domain/equipment_type.dart';
import 'equipment_providers.dart';

/// Handles creating/updating equipment with explicit loading/error/success so
/// the editor can render a real state for each (do-not-break rule #5). Mirrors
/// LogSessionController. Archive/restore are simple enough to call the
/// repository directly (with undo), like session delete.
class EquipmentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates a new equipment ([existing] null) or updates an existing one.
  /// Returns true on success. Name is trimmed; callers validate non-empty.
  Future<bool> save({
    Equipment? existing,
    required String name,
    required EquipmentType type,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(equipmentRepositoryProvider);
    final now = DateTime.now();

    final equipment = existing == null
        ? Equipment(
            id: IdGenerator.newId(),
            name: name.trim(),
            type: type,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(name: name.trim(), type: type, updatedAt: now);

    state = await AsyncValue.guard(() => repository.save(equipment));
    return !state.hasError;
  }
}

final equipmentControllerProvider =
    AsyncNotifierProvider<EquipmentController, void>(EquipmentController.new);
