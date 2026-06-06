import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_session_repository.dart';
import '../../domain/session_repository.dart';
import '../../domain/tennis_session.dart';

/// Exposes the repository via its domain interface, so the UI never sees Drift
/// (CLAUDE.md §2). Swap this override to change the backing store.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return DriftSessionRepository(ref.watch(appDatabaseProvider));
});

/// Live list of sessions for the history screen. StreamProvider so the UI
/// reflects writes automatically (CLAUDE.md §4 feedback, §6 reactive over poll).
final sessionListProvider = StreamProvider<List<TennisSession>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchSessions();
});
