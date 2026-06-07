import '../../../shared/domain/skill/skill_catalog.dart';
import '../../../shared/domain/skill/skill_category.dart';
import '../../../shared/domain/skill/skill_score.dart';
import 'category_score.dart';

/// Builds the Player Profile's category view from per-skill [SkillScore]s. Pure
/// and deterministic (same input → same output) so it's testable and could be
/// recomputed server-side (community-ready, ADR-007). No Flutter, no I/O.
///
/// Only the four directly-ratable categories form the radar axes; match-craft
/// and equipment are derived elsewhere and are not part of the skill catalog.
class PlayerProfileBuilder {
  PlayerProfileBuilder._();

  /// The radar axes, in a stable display order.
  static const List<SkillCategory> radarCategories = [
    SkillCategory.strokes,
    SkillCategory.shotQuality,
    SkillCategory.physical,
    SkillCategory.mental,
  ];

  /// One [CategoryScore] per radar category, averaging the scores of that
  /// category's skills. Categories with no rated skills come back with value 0
  /// (an honest "not started yet"), never omitted — so the radar shape is stable.
  static List<CategoryScore> categoryScores(List<SkillScore> scores) {
    final valueBySkill = {for (final s in scores) s.skillId: s.value};

    return radarCategories.map((category) {
      final skills = SkillCatalog.byCategory(category);
      var sum = 0.0;
      var rated = 0;
      for (final skill in skills) {
        final value = valueBySkill[skill.id];
        if (value != null) {
          sum += value;
          rated++;
        }
      }
      return CategoryScore(
        category: category,
        value: rated == 0 ? 0 : sum / rated,
        ratedSkillCount: rated,
      );
    }).toList();
  }

  /// Overall profile strength: the average of category values that have data
  /// (1..5), or 0 when nothing is rated yet. A single honest headline number.
  static double overall(List<CategoryScore> categories) {
    final withData = categories.where((c) => c.hasData).toList();
    if (withData.isEmpty) return 0;
    final sum = withData.fold<double>(0, (a, c) => a + c.value);
    return sum / withData.length;
  }
}
