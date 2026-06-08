/// Aggregated statistics for a single student, computed from their logged
/// sessions. Mirrors [SessionStats] (progress feature) but scoped to one
/// student. Deterministic and re-derivable from the raw session rows.
class StudentStats {
  final int totalSessions;
  final int matchCount;

  /// Matches where the trainer recorded a Win/Loss/Draw result.
  final int ratedMatchCount;
  final int winCount;
  final double? avgPerformance;
  final double? avgMood;
  final double? avgEnergy;

  const StudentStats({
    required this.totalSessions,
    required this.matchCount,
    required this.ratedMatchCount,
    required this.winCount,
    this.avgPerformance,
    this.avgMood,
    this.avgEnergy,
  });

  static const empty = StudentStats(
    totalSessions: 0,
    matchCount: 0,
    ratedMatchCount: 0,
    winCount: 0,
  );

  bool get isEmpty => totalSessions == 0;

  double? get winRate =>
      ratedMatchCount == 0 ? null : winCount / ratedMatchCount;
}
