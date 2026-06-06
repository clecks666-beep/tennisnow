import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The app's persistent shell: bottom navigation between Sessions and Progress,
/// plus the always-available "Log" action. Logging is the core loop, so its
/// entry point lives here and is reachable from every tab (CLAUDE.md §4).
///
/// Uses a StatefulNavigationShell so each tab keeps its own navigation state.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  void _goToTab(int index) {
    // initialLocation: re-tapping the current tab returns to its root.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/log'),
        icon: const Icon(Icons.add),
        label: const Text('Log session'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
