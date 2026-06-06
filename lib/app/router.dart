import 'package:go_router/go_router.dart';

import '../features/session_logging/presentation/screens/log_session_screen.dart';
import '../features/session_logging/presentation/screens/session_list_screen.dart';

/// Central navigation config (CLAUDE.md §2). New features add their routes here.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SessionListScreen(),
        routes: [
          GoRoute(
            path: 'log',
            builder: (context, state) => const LogSessionScreen(),
          ),
        ],
      ),
    ],
  );
}
