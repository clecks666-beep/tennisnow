import 'package:drift/drift.dart';

import '../../../shared/domain/rating.dart';
import '../domain/match_result.dart';
import '../domain/session_type.dart';
import '../domain/tennis_session.dart';
import 'app_database.dart';

/// Translates between the Drift row (`Session`) and the domain entity
/// (`TennisSession`). Keeps persistence types out of the domain (CLAUDE.md §2).
class SessionMapper {
  SessionMapper._();

  static TennisSession toDomain(Session row) {
    return TennisSession(
      id: row.id,
      type: SessionType.fromStorage(row.type),
      playedAt: row.playedAt,
      result: MatchResult.fromStorage(row.result),
      durationMinutes: row.durationMinutes,
      performance: Rating.tryFrom(row.performance),
      mood: Rating.tryFrom(row.mood),
      energy: Rating.tryFrom(row.energy),
      equipment: row.equipment,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static SessionsCompanion toCompanion(TennisSession session) {
    return SessionsCompanion(
      id: Value(session.id),
      type: Value(session.type.storageValue),
      playedAt: Value(session.playedAt),
      result: Value(session.result?.storageValue),
      durationMinutes: Value(session.durationMinutes),
      performance: Value(session.performance?.value),
      mood: Value(session.mood?.value),
      energy: Value(session.energy?.value),
      equipment: Value(session.equipment),
      note: Value(session.note),
      createdAt: Value(session.createdAt),
      updatedAt: Value(session.updatedAt),
      deletedAt: Value(session.deletedAt),
    );
  }
}
