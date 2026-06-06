import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/gamification/presentation/screens/achievements_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/session_logging/presentation/screens/log_session_screen.dart';
import '../features/session_logging/presentation/screens/session_list_screen.dart';
import 'home_shell.dart';

/// Central navigation config (CLAUDE.md §2).
///
/// A StatefulShellRoute hosts the two persistent tabs (Sessions, Progress)
/// inside [HomeShell]. The log flow is a top-level route pushed ABOVE the shell
/// so it presents full-screen over whichever tab is active. New tabbed features
/// add a branch; new full-screen flows add a top-level route.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/sessions',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sessions',
                builder: (context, state) => const SessionListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/log',
        parentNavigatorKey: _rootKey, // present above the shell (full screen)
        builder: (context, state) => const LogSessionScreen(),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const AchievementsScreen(),
      ),
    ],
  );
}
