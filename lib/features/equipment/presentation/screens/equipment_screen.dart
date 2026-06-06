import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../domain/equipment.dart';
import '../providers/equipment_providers.dart';
import '../widgets/equipment_editor_sheet.dart';
import '../widgets/equipment_tile.dart';

/// Manage the player's gear. Reached from Settings. Full state handling via
/// AsyncValueView + EmptyState (do-not-break rule #5).
class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipment = ref.watch(activeEquipmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My equipment')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEquipmentEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: AsyncValueView<List<Equipment>>(
        value: equipment,
        onRetry: () => ref.invalidate(activeEquipmentProvider),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.sports_tennis_rounded,
              title: 'Add your gear',
              message:
                  'Add your rackets, strings and shoes. Then pick them when you '
                  'log — and see what gear brings out your best tennis.',
              actionLabel: 'Add equipment',
              onAction: () => showEquipmentEditor(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.screen,
              96, // clear the FAB
            ),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _DismissibleEquipment(
              key: ValueKey(list[index].id),
              equipment: list[index],
            ),
          );
        },
      ),
    );
  }
}

/// Swipe-to-archive with undo — soft-delete + restore (CLAUDE.md §4,
/// do-not-break rule #3).
class _DismissibleEquipment extends ConsumerWidget {
  final Equipment equipment;

  const _DismissibleEquipment({super.key, required this.equipment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss_${equipment.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: const Icon(Icons.archive_outlined, color: Colors.red),
      ),
      onDismissed: (_) async {
        final repository = ref.read(equipmentRepositoryProvider);
        await repository.archive(equipment.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('${equipment.name} archived'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => repository.restore(equipment.id),
              ),
            ),
          );
      },
      child: EquipmentTile(
        equipment: equipment,
        onTap: () => showEquipmentEditor(context, existing: equipment),
      ),
    );
  }
}
