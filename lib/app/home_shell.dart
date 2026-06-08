import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/trainer/presentation/providers/trainer_providers.dart';

/// The app's persistent shell: bottom navigation between Sessions, Progress,
/// and (when trainer mode is on) Trainer. The "Log" FAB is always visible so
/// logging is reachable from every tab (CLAUDE.md §4).
///
/// Becomes a ConsumerWidget so it can watch trainerModeProvider and
/// conditionally show the third tab without rebuilding the route tree.
class HomeShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  void _goToTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainerEnabled = ref.watch(trainerModeProvider);

    // If trainer mode is disabled but the shell is still on the trainer branch
    // (branch index 2), bounce back to sessions so the nav bar stays valid.
    if (!trainerEnabled && navigationShell.currentIndex == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationShell.goBranch(0, initialLocation: true);
      });
    }

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Sessions',
      ),
      const NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Progress',
      ),
      if (trainerEnabled)
        const NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Trainer',
        ),
    ];

    // Clamp selectedIndex in case the branch count temporarily mismatches.
    final selectedIndex =
        navigationShell.currentIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/log'),
        icon: const Icon(Icons.add),
        label: const Text('Log session'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _goToTab,
        destinations: destinations,
      ),
    );
  }
}
