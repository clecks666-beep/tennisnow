import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../skills/presentation/providers/skill_rating_providers.dart';
import '../../domain/coach_context.dart';
import '../../domain/coach_insight.dart';
import '../../domain/rule_based_coach.dart';

/// Adapts existing PUBLIC providers (session stats, performance trend, skill
/// scores, gamification snapshot) into the coach's pre-aggregated
/// [CoachContext]. Composing another feature's public Riverpod provider is
/// allowed (CLAUDE.md §2); the coach DOMAIN stays free of cross-feature types —
/// the mapping to primitives happens here, at the edge.
final coachContextProvider = Provider<CoachContext>((ref) {
  final stats = ref.watch(sessionStatsProvider).valueOrNull;
  if (stats == null) return CoachContext.empty;

  final trend = ref.watch(performanceTrendProvider).valueOrNull ?? const [];
  final skills = ref.watch(skillScoresProvider).valueOrNull ?? const [];
  final gam = ref.watch(gamificationProvider).valueOrNull;

  return CoachContext(
    totalSessions: stats.totalSessions,
    matchCount: stats.matchCount,
    ratedMatchCount: stats.ratedMatchCount,
    winCount: stats.winCount,
    avgPerformance: stats.avgPerformance,
    avgMood: stats.avgMood,
    avgEnergy: stats.avgEnergy,
    performanceSeries: trend.map((p) => p.performance).toList(),
    skillScores: skills,
    streakCurrent: gam?.streak.current ?? 0,
    playerLevel: gam?.level.level ?? 1,
    playerTitle: gam?.level.title ?? 'Rookie',
  );
});

/// The current coaching read. Deterministic and offline today (zero tokens,
/// CLAUDE.md §6/§11). When a live model is wired in, the swap happens HERE —
/// try the AiClient when reachable, else fall back to [RuleBasedCoach] — so no
/// consumer of this provider changes.
final coachInsightProvider = Provider<CoachInsight>((ref) {
  return RuleBasedCoach.insight(ref.watch(coachContextProvider));
});
