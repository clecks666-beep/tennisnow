import '../domain/session_repository.dart';
import '../domain/tennis_session.dart';
import 'app_database.dart';
import 'session_mapper.dart';

/// Drift-backed implementation of [SessionRepository]. This is the only place
/// that knows about the database; the rest of the app uses the interface
/// (CLAUDE.md §2). A future cloud repository can replace this class.
class DriftSessionRepository implements SessionRepository {
  final AppDatabase _db;

  DriftSessionRepository(this._db);

  @override
  Stream<List<TennisSession>> watchSessions() {
    return _db.watchActiveSessions().map(
          (rows) => rows.map(SessionMapper.toDomain).toList(),
        );
  }

  @override
  Future<void> add(TennisSession session) {
    return _db.upsertSession(SessionMapper.toCompanion(session));
  }

  @override
  Future<void> softDelete(String id) {
    return _db.setDeletedAt(id, DateTime.now(), DateTime.now());
  }

  @override
  Future<void> restore(String id) {
    return _db.setDeletedAt(id, null, DateTime.now());
  }
}
