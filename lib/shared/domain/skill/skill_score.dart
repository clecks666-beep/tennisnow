/// A skill's current, recency-weighted self-assessment. Part of the cross-cutting
/// Tennis Skill Model (CLAUDE.md ★B: "Skill + SkillCategory + recency-weighted
/// aggregate"), so it lives in shared/domain — multiple features read it
/// (skills computes & shows it; player_profile aggregates it into the radar).
///
/// Derived (not stored) from the player's skill self-ratings by the skills
/// feature's calculator. Pure value object: no Flutter, no I/O.
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
