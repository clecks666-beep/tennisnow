import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/widgets/async_value_view.dart';
import '../../../../design_system/widgets/empty_state.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import '../../domain/tennis_session.dart';
import '../providers/session_providers.dart';
import '../widgets/session_list_tile.dart';

/// Home screen: the player's session history and the entry point to logging.
/// Handles loading / empty / error / success via AsyncValueView + EmptyState
/// (do-not-break rule #5).
class SessionListScreen extends ConsumerWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionListProvider);
    final name = ref.watch(
      settingsControllerProvider.select((s) => s.displayName),
    );

    // Note: the "Log session" FAB lives in HomeShell so it's available from
    // every tab — it is intentionally not duplicated here.
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null ? 'Your sessions' : '$name\'s sessions'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: AsyncValueView<List<TennisSession>>(
        value: sessions,
        onRetry: () => ref.invalidate(sessionListProvider),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.sports_tennis_rounded,
              title: 'Log your first session',
              message:
                  'Track how you played and how you felt. Over time you\'ll see '
                  'what brings out your best tennis.',
              actionLabel: 'Log a session',
              onAction: () => context.push('/log'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.screen,
              // Space so the FAB never covers the last row.
              96,
            ),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final session = list[index];
              return _DismissibleSession(
                key: ValueKey(session.id),
                session: session,
              );
            },
          );
        },
      ),
    );
  }
}

/// Swipe-to-delete with undo. Uses soft-delete + restore so the action is fully
/// recoverable (CLAUDE.md §4 recovery from mistakes; do-not-break rule #3).
class _DismissibleSession extends ConsumerWidget {
  final TennisSession session;

  const _DismissibleSession({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismiss_${session.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(),
      onDismissed: (_) async {
        final repository = ref.read(sessionRepositoryProvider);
        await repository.softDelete(session.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: const Text('Session deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => repository.restore(session.id),
              ),
            ),
          );
      },
      child: SessionListTile(
        session: session,
        onTap: () => context.push('/log', extra: session),
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.red),
    );
  }
}
