import 'session_stats.dart';
import 'trend_point.dart';

/// Domain contract for the read-only progress views. The UI depends on this
/// interface only — never on Drift (CLAUDE.md §2 dependency rule).
abstract interface class ProgressRepository {
  /// Live aggregate stats over all non-deleted sessions.
  Stream<SessionStats> watchStats();

  /// Live performance trend (oldest → newest) over the most recent rated
  /// sessions, bounded by [limit] so it never scans the full history.
  Stream<List<TrendPoint>> watchPerformanceTrend({int limit});
}
