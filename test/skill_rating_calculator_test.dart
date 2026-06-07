import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/skills/domain/skill_rating_calculator.dart';
import 'package:tennisnow/features/skills/domain/skill_self_rating.dart';

void main() {
  final now = DateTime(2026, 6, 7);

  SkillSelfRating rating(String skill, int value, int daysAgo) {
    final at = now.subtract(Duration(days: daysAgo));
    return SkillSelfRating(
      id: '$skill-$daysAgo',
      sessionId: 's',
      skillId: skill,
      value: value,
      recordedAt: at,
      createdAt: at,
      updatedAt: at,
    );
  }

  group('SkillRatingCalculator.scores', () {
    test('empty input -> no scores', () {
      expect(SkillRatingCalculator.scores([], now), isEmpty);
    });

    test('single rating yields that value', () {
      final s = SkillRatingCalculator.scores([rating('serve', 4, 0)], now);
      expect(s, hasLength(1));
      expect(s.first.skillId, 'serve');
      expect(s.first.value, closeTo(4.0, 1e-9));
      expect(s.first.sampleCount, 1);
    });

    test('recent ratings dominate older ones (recency weighting)', () {
      // halfLife 30d: a 60-day-old rating weighs 0.25 vs a fresh 1.0.
      final s = SkillRatingCalculator.scores(
        [rating('serve', 5, 0), rating('serve', 1, 60)],
        now,
        halfLifeDays: 30,
      );
      // (5*1 + 1*0.25) / 1.25 = 4.2
      expect(s.single.value, closeTo(4.2, 1e-9));
      expect(s.single.sampleCount, 2);
    });

    test('groups by skill and sorts best current form first', () {
      final s = SkillRatingCalculator.scores(
        [rating('serve', 2, 0), rating('backhand', 5, 0)],
        now,
      );
      expect(s.map((e) => e.skillId).toList(), ['backhand', 'serve']);
    });
  });
}
