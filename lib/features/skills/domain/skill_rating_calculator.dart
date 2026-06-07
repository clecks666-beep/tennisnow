import 'dart:math';

import '../../../core/constants/game_balance.dart';
import 'skill_score.dart';
import 'skill_self_rating.dart';

/// Turns raw skill self-ratings into per-skill [SkillScore]s, recency-weighted
/// so the score reflects CURRENT form (★ section). Pure & deterministic with an
/// injected `now`, so it is testable and server-recomputable (community-ready).
///
/// Weight of a rating = 0.5 ^ (ageDays / halfLife): a rating one half-life old
/// counts half as much as a fresh one.
class SkillRatingCalculator {
  SkillRatingCalculator._();

  static List<SkillScore> scores(
    List<SkillSelfRating> ratings,
    DateTime now, {
    double halfLifeDays = GameBalance.skillRecencyHalfLifeDays,
  }) {
    final bySkill = <String, List<SkillSelfRating>>{};
    for (final r in ratings) {
      bySkill.putIfAbsent(r.skillId, () => []).add(r);
    }

    final result = <SkillScore>[];
    bySkill.forEach((skillId, list) {
      var weightSum = 0.0;
      var valueSum = 0.0;
      for (final r in list) {
        final ageDays = now.difference(r.recordedAt).inDays.toDouble();
        final weight = pow(0.5, (ageDays < 0 ? 0.0 : ageDays) / halfLifeDays)
            .toDouble();
        weightSum += weight;
        valueSum += r.value * weight;
      }
      result.add(
        SkillScore(
          skillId: skillId,
          value: weightSum == 0 ? 0 : valueSum / weightSum,
          sampleCount: list.length,
        ),
      );
    });

    // Best current form first.
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }
}
