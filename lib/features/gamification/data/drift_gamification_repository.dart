import '../../../core/utils/combine_latest.dart';
import '../../../shared/data/app_database.dart';
import '../domain/badge_catalog.dart';
import '../domain/gamification_repository.dart';
import '../domain/gamification_snapshot.dart';
import '../domain/streak.dart';
import '../domain/streak_calculator.dart';

/// Drift-backed [GamificationRepository]. Read-only and derived: it combines the
/// existing SQL aggregates (counts) with the session dates (streak) — no new
/// tables or persistence. Counts stay in SQL; only the inherently-sequential
/// streak is computed in Dart (CLAUDE.md §6, memory.md.txt).
class DriftGamificationRepository implements GamificationRepository {
  final AppDatabase _db;

  /// Injectable clock keeps streak logic deterministic and testable.
  final DateTime Function() _now;

  DriftGamificationRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  @override
  Stream<GamificationSnapshot> watch() {
    return combineLatest2(
      _db.watchSessionAggregates(),
      _db.watchActiveSessionDates(),
      (SessionAggregates agg, List<DateTime> dates) {
        final Streak streak = StreakCalculator.compute(dates, _now());
        final inputs = GamificationInputs(
          totalSessions: agg.total,
          streakDays: streak.current,
          matches: agg.matchCount,
          wins: agg.winCount,
        );
        return GamificationSnapshot(
          streak: streak,
          achievements: BadgeCatalog.evaluate(inputs),
        );
      },
    );
  }
}
