import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../core/constants/app_constants.dart';

part 'app_database.g.dart';

/// Drift table for sessions. Column set follows the sync-ready invariant
/// (id/createdAt/updatedAt/deletedAt) from do-not-break rule #3.
///
/// Enums and value objects are stored primitively (text/int); mapping to/from
/// domain types happens in the data layer's mapper, keeping the domain pure.
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get playedAt => dateTime()();
  TextColumn get result => text().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get performance => integer().nullable()();
  IntColumn get mood => integer().nullable()();
  IntColumn get energy => integer().nullable()();
  TextColumn get equipment => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Allows tests to inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// Reactive query: non-deleted sessions, newest first. Filtering of
  /// soft-deleted rows happens in SQL, not in Dart (CLAUDE.md §6).
  Stream<List<Session>> watchActiveSessions() {
    return (select(sessions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]))
        .watch();
  }

  Future<void> upsertSession(SessionsCompanion entry) {
    return into(sessions).insertOnConflictUpdate(entry);
  }

  Future<void> setDeletedAt(String id, DateTime? deletedAt, DateTime updatedAt) {
    return (update(sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}

QueryExecutor _openConnection() {
  // drift_flutter resolves a platform-appropriate on-device path and opens
  // SQLite. Local-first, offline by default (CLAUDE.md §6, ADR-001).
  return driftDatabase(name: AppConstants.databaseName);
}
