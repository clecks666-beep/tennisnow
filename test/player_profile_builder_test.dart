import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/player_profile/domain/player_profile_builder.dart';
import 'package:tennisnow/shared/domain/skill/skill_category.dart';
import 'package:tennisnow/shared/domain/skill/skill_score.dart';

void main() {
  SkillScore score(String id, double value) =>
      SkillScore(skillId: id, value: value, sampleCount: 1);

  group('PlayerProfileBuilder.categoryScores', () {
    test('always returns the four radar categories in stable order', () {
      final cats = PlayerProfileBuilder.categoryScores([]);
      expect(
        cats.map((c) => c.category).toList(),
        [
          SkillCategory.strokes,
          SkillCategory.shotQuality,
          SkillCategory.physical,
          SkillCategory.mental,
        ],
      );
    });

    test('empty input -> every category has no data and value 0', () {
      final cats = PlayerProfileBuilder.categoryScores([]);
      expect(cats.every((c) => !c.hasData), isTrue);
      expect(cats.every((c) => c.value == 0), isTrue);
      expect(cats.every((c) => c.fraction == 0), isTrue);
    });

    test('averages only the rated skills within a category', () {
      // serve & backhand are strokes; rate two of the nine.
      final cats = PlayerProfileBuilder.categoryScores([
        score('serve', 5),
        score('backhand', 3),
      ]);
      final strokes = cats.firstWhere((c) => c.category == SkillCategory.strokes);
      expect(strokes.ratedSkillCount, 2);
      expect(strokes.value, closeTo(4.0, 1e-9)); // (5+3)/2
      expect(strokes.hasData, isTrue);
      // fraction maps 1..5 -> 0..1: (4-1)/4 = 0.75
      expect(strokes.fraction, closeTo(0.75, 1e-9));
    });

    test('skills land in their correct category', () {
      final cats = PlayerProfileBuilder.categoryScores([
        score('focus', 4), // mental
        score('power', 2), // shot quality
      ]);
      final mental = cats.firstWhere((c) => c.category == SkillCategory.mental);
      final shot =
          cats.firstWhere((c) => c.category == SkillCategory.shotQuality);
      expect(mental.value, closeTo(4.0, 1e-9));
      expect(shot.value, closeTo(2.0, 1e-9));
      // Untouched categories stay empty.
      final physical =
          cats.firstWhere((c) => c.category == SkillCategory.physical);
      expect(physical.hasData, isFalse);
    });

    test('unknown skill ids are ignored', () {
      final cats = PlayerProfileBuilder.categoryScores([score('not_a_skill', 5)]);
      expect(cats.every((c) => !c.hasData), isTrue);
    });
  });

  group('PlayerProfileBuilder.overall', () {
    test('is 0 when nothing is rated', () {
      final cats = PlayerProfileBuilder.categoryScores([]);
      expect(PlayerProfileBuilder.overall(cats), 0);
    });

    test('averages only categories that have data', () {
      final cats = PlayerProfileBuilder.categoryScores([
        score('serve', 4), // strokes -> 4.0
        score('focus', 2), // mental  -> 2.0
      ]);
      // Only two categories have data: (4 + 2) / 2 = 3.0
      expect(PlayerProfileBuilder.overall(cats), closeTo(3.0, 1e-9));
    });
  });

  group('PlayerProfileBuilder.strongest', () {
    test('is null when nothing is rated', () {
      final cats = PlayerProfileBuilder.categoryScores([]);
      expect(PlayerProfileBuilder.strongest(cats), isNull);
    });

    test('picks the highest-rated category among those with data', () {
      final cats = PlayerProfileBuilder.categoryScores([
        score('serve', 3), // strokes -> 3.0
        score('focus', 5), // mental  -> 5.0
        score('power', 2), // shot quality -> 2.0
      ]);
      expect(PlayerProfileBuilder.strongest(cats)!.category,
          SkillCategory.mental);
    });

    test('ignores empty categories and never returns a no-data one', () {
      final cats = PlayerProfileBuilder.categoryScores([score('serve', 4)]);
      final strongest = PlayerProfileBuilder.strongest(cats)!;
      expect(strongest.category, SkillCategory.strokes);
      expect(strongest.hasData, isTrue);
    });
  });

  group('PlayerProfileBuilder.focus', () {
    test('is null when nothing is rated yet (no signal to act on)', () {
      final cats = PlayerProfileBuilder.categoryScores([]);
      expect(PlayerProfileBuilder.focus(cats), isNull);
    });

    test('prefers a not-yet-started category once anything is rated', () {
      // Only strokes rated -> the first untouched category (shotQuality) is the
      // clearest next step.
      final cats = PlayerProfileBuilder.categoryScores([score('serve', 5)]);
      final focus = PlayerProfileBuilder.focus(cats)!;
      expect(focus.category, SkillCategory.shotQuality);
      expect(focus.hasData, isFalse);
    });

    test('nudges toward the weakest area when all categories are started', () {
      final cats = PlayerProfileBuilder.categoryScores([
        score('serve', 5), // strokes
        score('power', 4), // shot quality
        score('endurance', 2), // physical -> weakest
        score('focus', 3), // mental
      ]);
      expect(
          PlayerProfileBuilder.focus(cats)!.category, SkillCategory.physical);
    });

    test('strongest and focus differ once more than one area has data', () {
      final cats = PlayerProfileBuilder.categoryScores([
        score('serve', 5), // strokes
        score('focus', 2), // mental
      ]);
      final strongest = PlayerProfileBuilder.strongest(cats)!;
      final focus = PlayerProfileBuilder.focus(cats)!;
      expect(strongest.category, SkillCategory.strokes);
      // shotQuality & physical are untouched -> focus points at the first one.
      expect(focus.category, isNot(strongest.category));
    });
  });
}
