import '../../../shared/domain/skill/skill_category.dart';

/// A skill category's current standing on the Player Profile radar — the average
/// of the player's recency-weighted skill scores within that category. Pure,
/// derived value object (no Flutter, no I/O).
class CategoryScore {
  final SkillCategory category;

  /// Average recency-weighted value on the 1..5 scale, or 0 when the category
  /// has no rated skills yet.
  final double value;

  /// How many distinct skills in this category have a score.
  final int ratedSkillCount;

  const CategoryScore({
    required this.category,
    required this.value,
    required this.ratedSkillCount,
  });

  /// Whether the player has rated any skill in this category.
  bool get hasData => ratedSkillCount > 0;

  /// 0..1 for the radar axis (1..5 → 0..1); 0 when there's no data.
  double get fraction =>
      value <= 0 ? 0.0 : ((value - 1) / 4).clamp(0, 1).toDouble();
}
