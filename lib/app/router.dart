import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backup/presentation/screens/backup_screen.dart';
import '../features/equipment/presentation/screens/equipment_screen.dart';
import '../features/gamification/presentation/screens/achievements_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/player_profile/presentation/screens/player_profile_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/session_logging/domain/tennis_session.dart';
import '../features/session_logging/presentation/screens/log_session_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/session_logging/presentation/screens/session_list_screen.dart';
import '../features/trainer/presentation/screens/student_profile_screen.dart';
import '../features/trainer/presentation/screens/trainer_screen.dart';
import '../shared/data/app_preferences.dart';
import 'home_shell.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Central navigation config (CLAUDE.md §2), exposed as a provider so it can
/// read device-local preferences for the onboarding gate.
///
/// A StatefulShellRoute hosts the two persistent tabs (Sessions, Progress)
/// inside [HomeShell]. Full-screen/detail flows (logging, achievements,
/// onboarding) are top-level routes above the shell. The `redirect` shows
/// onboarding once on first launch and never again. New tabbed features add a
/// branch; new full-screen flows add a top-level route.
final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(appPreferencesProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/sessions',
    redirect: (context, state) {
      final onboarded = prefs.onboardingComplete;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/sessions';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trainer',
                builder: (context, state) => const TrainerScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/log',
        parentNavigatorKey: _rootKey, // present above the shell (full screen)
        // `extra` carries a TennisSession when editing an existing entry.
        builder: (context, state) =>
            LogSessionScreen(existing: state.extra as TennisSession?),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const PlayerProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/equipment',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const EquipmentScreen(),
      ),
      GoRoute(
        path: '/backup',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/trainer/student/:id',
        parentNavigatorKey: _rootKey, // detail screen above the shell
        builder: (context, state) => StudentProfileScreen(
          studentId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
