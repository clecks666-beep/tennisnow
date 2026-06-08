import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/coach/domain/coach_context.dart';
import 'package:tennisnow/features/coach/domain/coach_insight.dart';
import 'package:tennisnow/features/coach/domain/rule_based_coach.dart';
import 'package:tennisnow/shared/domain/skill/skill_score.dart';

/// Builds a context with sensible defaults so each test sets only what it
/// exercises. Mirrors the real edge-adapter shape (primitives + skill scores).
CoachContext ctx({
  int totalSessions = 5,
  int matchCount = 0,
  int ratedMatchCount = 0,
  int winCount = 0,
  double? avgPerformance,
  double? avgMood,
  double? avgEnergy,
  List<int> performanceSeries = const [],
  List<SkillScore> skillScores = const [],
  int streakCurrent = 0,
  int playerLevel = 1,
  String playerTitle = 'Rookie',
}) {
  return CoachContext(
    totalSessions: totalSessions,
    matchCount: matchCount,
    ratedMatchCount: ratedMatchCount,
    winCount: winCount,
    avgPerformance: avgPerformance,
    avgMood: avgMood,
    avgEnergy: avgEnergy,
    performanceSeries: performanceSeries,
    skillScores: skillScores,
    streakCurrent: streakCurrent,
    playerLevel: playerLevel,
    playerTitle: playerTitle,
  );
}

SkillScore score(String id, double value) =>
    SkillScore(skillId: id, value: value, sampleCount: 3);

void main() {
  group('CoachContext', () {
    test('winRate is null without rated matches, else a fraction', () {
      expect(ctx().winRate, isNull);
      expect(ctx(ratedMatchCount: 4, winCount: 3).winRate, closeTo(0.75, 1e-9));
    });

    test('performanceTrendDelta needs at least two points', () {
      expect(ctx(performanceSeries: const [3]).performanceTrendDelta, isNull);
    });

    test('performanceTrendDelta compares recent half to earlier half', () {
      // earlier [2,2] avg 2, recent [4,4] avg 4 -> +2
      final d = ctx(performanceSeries: const [2, 2, 4, 4]).performanceTrendDelta;
      expect(d, closeTo(2.0, 1e-9));
    });

    test('weakestSkill picks the lowest value, breaking ties by skillId', () {
      final c = ctx(skillScores: [score('serve', 2.0), score('backhand', 2.0)]);
      // tie at 2.0 -> 'backhand' < 'serve' alphabetically
      expect(c.weakestSkill?.skillId, 'backhand');
    });

    test('weakestSkill is null when no skills are tagged', () {
      expect(ctx().weakestSkill, isNull);
    });
  });

  group('RuleBasedCoach', () {
    test('empty context sells the first session and is rule-sourced', () {
      final insight = RuleBasedCoach.insight(CoachContext.empty);
      expect(insight.source, CoachSource.rule);
      expect(insight.headline.toLowerCase(), contains('session'));
      expect(insight.focusSkillId, isNull);
    });

    test('streak of 3+ leads the headline', () {
      final insight = RuleBasedCoach.insight(ctx(streakCurrent: 4));
      expect(insight.headline, contains('4-day streak'));
      expect(insight.basis, contains('4-day streak'));
    });

    test('win rate headline when enough rated matches and no streak', () {
      final insight = RuleBasedCoach.insight(
        ctx(matchCount: 5, ratedMatchCount: 5, winCount: 3),
      );
      expect(insight.headline, contains('60%'));
      expect(insight.basis, contains('win rate 60%'));
    });

    test('falls back to average performance headline', () {
      final insight = RuleBasedCoach.insight(ctx(avgPerformance: 3.4));
      expect(insight.headline, contains('3.4/5'));
    });

    test('focuses the lowest-rated skill and names it in the body', () {
      final insight = RuleBasedCoach.insight(
        ctx(skillScores: [score('serve', 4.0), score('backhand', 2.0)]),
      );
      expect(insight.focusSkillId, 'backhand');
      expect(insight.body, contains('Backhand'));
      expect(insight.basis, contains('lowest: Backhand'));
    });

    test('nudges skill tagging when no skills are tagged', () {
      final insight = RuleBasedCoach.insight(ctx());
      expect(insight.focusSkillId, isNull);
      expect(insight.body.toLowerCase(), contains('tag the skills'));
    });

    test('reads an upward trend honestly', () {
      final insight = RuleBasedCoach.insight(
        ctx(performanceSeries: const [2, 2, 4, 4]),
      );
      expect(insight.body.toLowerCase(), contains('trending up'));
    });

    test('reads a dip and offers a reset', () {
      final insight = RuleBasedCoach.insight(
        ctx(performanceSeries: const [4, 4, 2, 2]),
      );
      expect(insight.body.toLowerCase(), contains('reset'));
    });
  });
}
