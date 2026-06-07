import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';

part 'app_database.g.dart';

/// The single, app-wide local database. Lives in shared/data because more than
/// one feature reads from it (session_logging writes; progress reads aggregates)
/// — keeping it here avoids a feature depending on another feature's internals
/// (CLAUDE.md §2).
///
/// Drift table for sessions. Column set follows the sync-ready invariant
/// (id/createdAt/updatedAt/deletedAt) from do-not-break rule #3. Enums and value
/// objects are stored primitively; mapping to/from domain happens in mappers so
/// the domain stays pure.
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

/// Drift table for the user's equipment (rackets, strings, shoes…). Same
/// sync-ready invariant as sessions. Named *Items* so the generated row class is
/// `EquipmentItem`, leaving the domain entity free to be `Equipment` (mirrors the
/// Sessions/`Session` vs `TennisSession` split).
class EquipmentItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  // Stringing details (rackets) — all optional.
  TextColumn get stringName => text().nullable()();
  RealColumn get tensionKg => real().nullable()();
  DateTimeColumn get lastStrungAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single skill self-rating recorded with a session (the "what I worked on"
/// capture). Owned by its session; the active aggregate joins on the session so
/// ratings of a deleted session drop out. Sync-ready invariant columns included.
class SkillRatings extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get skillId => text()();
  IntColumn get value => integer()(); // 1..5
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Plain data-layer carrier for aggregate results. Kept out of the domain so the
/// shared DB never imports a feature's domain types; repositories map it across.
class SessionAggregates {
  final int total;
  final int matchCount;
  final int ratedMatchCount;
  final int winCount;
  final double? avgPerformance;
  final double? avgMood;
  final double? avgEnergy;

  const SessionAggregates({
    required this.total,
    required this.matchCount,
    required this.ratedMatchCount,
    required this.winCount,
    required this.avgPerformance,
    required this.avgMood,
    required this.avgEnergy,
  });
}

/// Per-equipment performance aggregate (data-layer carrier).
class EquipmentPerformanceRow {  final String name;
  final double avgPerformance;
  final int sessions;

  const EquipmentPerformanceRow({
    required this.name,
    required this.avgPerformance,
    required this.sessions,
  });
}

@DriftDatabase(tables: [Sessions, EquipmentItems, SkillRatings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Allows tests to inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  /// Schema migrations. ANY schema change must bump [schemaVersion] and add an
  /// upgrade step here so existing on-device data is never broken (CLAUDE.md §2,
  /// ADR-006). v1→v2 adds equipment; v2→v3 adds stringing columns; v3→v4 adds
  /// the skill-ratings table.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(equipmentItems);
          }
          if (from < 3) {
            await m.addColumn(equipmentItems, equipmentItems.stringName);
            await m.addColumn(equipmentItems, equipmentItems.tensionKg);
            await m.addColumn(equipmentItems, equipmentItems.lastStrungAt);
          }
          if (from < 4) {
            await m.createTable(skillRatings);
          }
        },
      );

  // ---- session_logging reads/writes ----

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

  // ---- progress reads (aggregation pushed into SQL, CLAUDE.md §6) ----

  /// One-row reactive aggregate over all non-deleted sessions. Uses filtered
  /// counts and averages so the whole stat block is a single, cheap query.
  Stream<SessionAggregates> watchSessionAggregates() {
    final total = sessions.id.count();
    final matchCount =
        sessions.id.count(filter: sessions.type.equals('match'));
    final ratedMatchCount =
        sessions.id.count(filter: sessions.result.isNotNull());
    final winCount = sessions.id.count(filter: sessions.result.equals('win'));
    final avgPerformance = sessions.performance.avg();
    final avgMood = sessions.mood.avg();
    final avgEnergy = sessions.energy.avg();

    final query = selectOnly(sessions)
      ..addColumns([
        total,
        matchCount,
        ratedMatchCount,
        winCount,
        avgPerformance,
        avgMood,
        avgEnergy,
      ])
      ..where(sessions.deletedAt.isNull());

    return query.watchSingle().map(
          (row) => SessionAggregates(
            total: row.read(total) ?? 0,
            matchCount: row.read(matchCount) ?? 0,
            ratedMatchCount: row.read(ratedMatchCount) ?? 0,
            winCount: row.read(winCount) ?? 0,
            avgPerformance: row.read(avgPerformance),
            avgMood: row.read(avgMood),
            avgEnergy: row.read(avgEnergy),
          ),
        );
  }

  /// Played-at timestamps of all non-deleted sessions, newest first. Selects a
  /// single column (not whole rows) for the streak calculation, which is
  /// inherently sequential and not expressible in portable SQL.
  Stream<List<DateTime>> watchActiveSessionDates() {
    final query = selectOnly(sessions)
      ..addColumns([sessions.playedAt])
      ..where(sessions.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(sessions.playedAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.read(sessions.playedAt)!).toList());
  }

  /// Most recent sessions that have a performance rating, newest first.
  /// Bounded by [limit] so this never scans the full history (CLAUDE.md §6).
  Stream<List<Session>> watchRecentRatedSessions({required int limit}) {
    return (select(sessions)
          ..where((t) => t.deletedAt.isNull() & t.performance.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(limit))
        .watch();
  }

  // ---- equipment reads/writes ----

  /// Non-archived equipment, alphabetical (soft-delete filtered in SQL).
  Stream<List<EquipmentItem>> watchActiveEquipment() {
    return (select(equipmentItems)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<void> upsertEquipment(EquipmentItemsCompanion entry) {
    return into(equipmentItems).insertOnConflictUpdate(entry);
  }

  Future<void> setEquipmentDeletedAt(
    String id,
    DateTime? deletedAt,
    DateTime updatedAt,
  ) {
    return (update(equipmentItems)..where((t) => t.id.equals(id))).write(
      EquipmentItemsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  // ---- one-shot reads for backup/export ----

  Future<List<Session>> allActiveSessionsOnce() {
    return (select(sessions)..where((t) => t.deletedAt.isNull())).get();
  }

  Future<List<EquipmentItem>> allActiveEquipmentOnce() {
    return (select(equipmentItems)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Active skill ratings whose session is also active (inner join), for backup.
  /// Mirrors [watchActiveSkillRatings] but one-shot, so a tombstoned session's
  /// ratings never leak into an export.
  Future<List<SkillRating>> allActiveSkillRatingsOnce() {
    final query = select(skillRatings).join([
      innerJoin(
        sessions,
        sessions.id.equalsExp(skillRatings.sessionId),
        useColumns: false,
      ),
    ])
      ..where(skillRatings.deletedAt.isNull() & sessions.deletedAt.isNull());
    return query
        .get()
        .then((rows) => rows.map((r) => r.readTable(skillRatings)).toList());
  }

  /// Merge-by-UUID upsert for restoring a skill rating from a backup. Matches
  /// the upsert semantics used for sessions/equipment so re-importing is safe.
  Future<void> upsertSkillRating(SkillRatingsCompanion entry) {
    return into(skillRatings).insertOnConflictUpdate(entry);
  }

  // ---- skill self-ratings ----

  /// Active skill ratings whose session is also active (inner join), so ratings
  /// of a soft-deleted session drop out without touching the rating rows.
  Stream<List<SkillRating>> watchActiveSkillRatings() {
    final query = select(skillRatings).join([
      innerJoin(
        sessions,
        sessions.id.equalsExp(skillRatings.sessionId),
        useColumns: false,
      ),
    ])
      ..where(skillRatings.deletedAt.isNull() & sessions.deletedAt.isNull());
    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(skillRatings)).toList());
  }

  /// Count of DISTINCT active sessions that carry at least one active skill
  /// rating — the input for the skill-work XP bonus (★C). Inner-joins active
  /// sessions so a soft-deleted session (or its tombstoned ratings) drops out.
  /// Counting distinct sessions (not ratings) keeps the bonus honest in SQL.
  Stream<int> watchSkillTaggedSessionCount() {
    final distinctSessions = skillRatings.sessionId.count(distinct: true);
    final query = selectOnly(skillRatings).join([
      innerJoin(
        sessions,
        sessions.id.equalsExp(skillRatings.sessionId),
        useColumns: false,
      ),
    ])
      ..addColumns([distinctSessions])
      ..where(skillRatings.deletedAt.isNull() & sessions.deletedAt.isNull());
    return query
        .watchSingle()
        .map((row) => row.read(distinctSessions) ?? 0);
  }

  Future<List<SkillRating>> skillRatingsForSession(String sessionId) {
    return (select(skillRatings)
          ..where((t) => t.sessionId.equals(sessionId) & t.deletedAt.isNull()))
        .get();
  }

  /// Replaces a session's skill ratings: soft-deletes the existing active ones
  /// (sync-safe tombstone) and inserts the new set, in one transaction.
  Future<void> replaceSkillRatingsForSession(
    String sessionId,
    List<SkillRatingsCompanion> rows,
    DateTime now,
  ) {
    return transaction(() async {
      await (update(skillRatings)
            ..where((t) => t.sessionId.equals(sessionId) & t.deletedAt.isNull()))
          .write(SkillRatingsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      for (final row in rows) {
        await into(skillRatings).insert(row);
      }
    });
  }

  /// Average performance grouped by the equipment recorded on sessions, best
  /// first. Grouping/averaging happen in SQL, not Dart (CLAUDE.md §6). Only
  /// sessions that recorded both equipment and a performance rating count.
  Stream<List<EquipmentPerformanceRow>> watchPerformanceByEquipment() {
    final name = sessions.equipment;
    final avg = sessions.performance.avg();
    final count = sessions.id.count();

    final query = selectOnly(sessions)
      ..addColumns([name, avg, count])
      ..where(sessions.deletedAt.isNull() &
          sessions.equipment.isNotNull() &
          sessions.performance.isNotNull())
      ..groupBy([sessions.equipment])
      ..orderBy([OrderingTerm(expression: avg, mode: OrderingMode.desc)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (r) => EquipmentPerformanceRow(
                  name: r.read(name)!,
                  avgPerformance: r.read(avg)!,
                  sessions: r.read(count) ?? 0,
                ),
              )
              .toList(),
        );
  }
}

QueryExecutor _openConnection() {
  // drift_flutter resolves a platform-appropriate on-device path and opens
  // SQLite. Local-first, offline by default (CLAUDE.md §6, ADR-001).
  //
  // On web there is no native SQLite, so drift runs sqlite3 compiled to
  // WebAssembly inside a worker. Those two assets (`sqlite3.wasm`,
  // `drift_worker.js`) must be served from the web root — the CI `pages`
  // workflow downloads them into web/ before `flutter build web`. We pass the
  // URIs explicitly so web behaviour is deterministic and never silently
  // falls back to a broken in-memory database. Ignored on iOS/Android.
  return driftDatabase(
    name: AppConstants.databaseName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
