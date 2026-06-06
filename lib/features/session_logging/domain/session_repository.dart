import 'tennis_session.dart';

/// Domain contract for session persistence. The presentation layer depends on
/// this interface only — never on Drift (CLAUDE.md §2 dependency rule). A future
/// cloud-sync implementation can be swapped in without touching the UI.
abstract interface class SessionRepository {
  /// Live stream of non-deleted sessions, newest first. Backed by a reactive
  /// query so the UI updates automatically after writes (CLAUDE.md §4 feedback).
  Stream<List<TennisSession>> watchSessions();

  /// Persists a new session.
  Future<void> add(TennisSession session);

  /// Soft-deletes by id (sets deletedAt) so the row remains sync-safe and the
  /// action is recoverable via [restore] (do-not-break rule #3, CLAUDE.md §4).
  Future<void> softDelete(String id);

  /// Reverses a soft-delete — powers undo.
  Future<void> restore(String id);
}
