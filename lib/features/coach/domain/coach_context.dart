import '../../../shared/domain/skill/skill_score.dart';

/// The compact, pre-aggregated snapshot the coach reasons over — and, crucially,
/// the exact payload a future LLM call receives (CLAUDE.md §11 cost rule: hand
/// the model small, already-aggregated numbers, never raw session history).
///
/// Pure domain (no Flutter, no I/O) and deliberately built from PRIMITIVES plus
/// the shared [SkillScore] model only — never another feature's domain types —
/// so it honours the dependency rule (§2) and stays server/community-portable.
/// The presentation layer adapts existing aggregates (session stats, trend,
/// gamification snapshot) into this at the edge.
class CoachContext {
  final int totalSessions;
  final int matchCount;

  /// Matches with a recorded result — the denominator for win rate.
  final int ratedMatchCount;
  final int winCount;

  /// Optional self-rated averages (1..5); null when the player skipped them.
  final double? avgPerformance;
  final double? avgMood;
  final double? avgEnergy;

  /// Performance ratings (1..5) of recent rated sessions, oldest → newest.
  /// Used to read direction of form; kept as plain ints so the coach domain
  /// stays decoupled from the progress feature's TrendPoint.
  final List<int> performanceSeries;

  /// Current recency-weighted skill self-assessments (shared model).
  final List<SkillScore> skillScores;

  final int streakCurrent;
  final int playerLevel;
  final String playerTitle;

  const CoachContext({
    required this.totalSessions,
    required this.matchCount,
    required this.ratedMatchCount,
    required this.winCount,
    required this.avgPerformance,
    required this.avgMood,
    required this.avgEnergy,
    required this.performanceSeries,
    required this.skillScores,
    required this.streakCurrent,
    required this.playerLevel,
    required this.playerTitle,
  });

  static const empty = CoachContext(
    totalSessions: 0,
    matchCount: 0,
    ratedMatchCount: 0,
    winCount: 0,
    avgPerformance: null,
    avgMood: null,
    avgEnergy: null,
    performanceSeries: [],
    skillScores: [],
    streakCurrent: 0,
    playerLevel: 1,
    playerTitle: 'Rookie',
  );

  bool get isEmpty => totalSessions == 0;

  /// Fraction 0..1 of decided matches won, or null if none are rated yet.
  double? get winRate =>
      ratedMatchCount == 0 ? null : winCount / ratedMatchCount;

  /// Recent-half minus earlier-half average performance, or null when there
  /// aren't enough rated points to compare. Positive = trending up.
  double? get performanceTrendDelta {
    final s = performanceSeries;
    if (s.length < 2) return null;
    final mid = s.length ~/ 2;
    final earlier = s.sublist(0, mid);
    final recent = s.sublist(mid);
    double avg(List<int> xs) =>
        xs.fold<int>(0, (a, b) => a + b) / xs.length;
    return avg(recent) - avg(earlier);
  }

  /// The lowest-rated skill — the most honest "work on this next" target —
  /// or null when no skills have been tagged yet. Deterministic: ties break on
  /// skillId so the same input always yields the same nudge (community-ready).
  SkillScore? get weakestSkill {
    SkillScore? worst;
    for (final s in skillScores) {
      if (worst == null ||
          s.value < worst.value ||
          (s.value == worst.value && s.skillId.compareTo(worst.skillId) < 0)) {
        worst = s;
      }
    }
    return worst;
  }
}
