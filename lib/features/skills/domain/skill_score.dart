/// A skill's current, recency-weighted self-assessment. Derived (not stored)
/// from the player's [SkillSelfRating]s by [SkillRatingCalculator].
class SkillScore {
  final String skillId;

  /// Recency-weighted value on the 1..5 scale.
  final double value;

  /// How many self-ratings fed this score.
  final int sampleCount;

  const SkillScore({
    required this.skillId,
    required this.value,
    required this.sampleCount,
  });

  /// Convenience 0..1 for bars/radars.
  double get fraction => ((value - 1) / 4).clamp(0, 1);
}
