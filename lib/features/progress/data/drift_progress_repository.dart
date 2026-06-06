import '../../../shared/data/app_database.dart';
import '../domain/progress_repository.dart';
import '../domain/session_stats.dart';
import '../domain/trend_point.dart';

/// Drift-backed [ProgressRepository]. Reads aggregates/rows from the shared
/// AppDatabase and maps them to pure domain types, keeping the domain free of
/// persistence concerns (CLAUDE.md §2). Read-only — it never mutates data.
class DriftProgressRepository implements ProgressRepository {
  final AppDatabase _db;

  DriftProgressRepository(this._db);

  @override
  Stream<SessionStats> watchStats() {
    return _db.watchSessionAggregates().map(
          (a) => SessionStats(
            totalSessions: a.total,
            matchCount: a.matchCount,
            ratedMatchCount: a.ratedMatchCount,
            winCount: a.winCount,
            avgPerformance: a.avgPerformance,
            avgMood: a.avgMood,
            avgEnergy: a.avgEnergy,
          ),
        );
  }

  @override
  Stream<List<TrendPoint>> watchPerformanceTrend({int limit = 12}) {
    return _db.watchRecentRatedSessions(limit: limit).map(
          // DB returns newest-first; reverse to chronological for the chart.
          (rows) => rows.reversed
              .map(
                (r) => TrendPoint(
                  playedAt: r.playedAt,
                  performance: r.performance!,
                ),
              )
              .toList(),
        );
  }
}
