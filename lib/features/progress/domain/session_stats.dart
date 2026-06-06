/// Aggregate view of the player's logged sessions. Pure domain object
/// (no Flutter, no persistence). Averages are nullable because the user may
/// have skipped those optional ratings (CLAUDE.md §4).
class SessionStats {
  final int totalSessions;
  final int matchCount;

  /// Matches that have a recorded result — the denominator for win rate.
  final int ratedMatchCount;
  final int winCount;

  final double? avgPerformance;
  final double? avgMood;
  final double? avgEnergy;

  const SessionStats({
    required this.totalSessions,
    required this.matchCount,
    required this.ratedMatchCount,
    required this.winCount,
    required this.avgPerformance,
    required this.avgMood,
    required this.avgEnergy,
  });

  static const empty = SessionStats(
    totalSessions: 0,
    matchCount: 0,
    ratedMatchCount: 0,
    winCount: 0,
    avgPerformance: null,
    avgMood: null,
    avgEnergy: null,
  );

  bool get isEmpty => totalSessions == 0;

  /// Fraction 0..1 of decided matches won, or null if no rated matches yet.
  double? get winRate =>
      ratedMatchCount == 0 ? null : winCount / ratedMatchCount;
}
