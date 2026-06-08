/// A single skill rating logged by a trainer for a student during a session.
/// Mirrors [SkillSelfRating] but owned by the trainer feature and linked to a
/// [StudentSession] rather than a [TennisSession]. Carries the same sync-ready
/// invariants (id, createdAt, updatedAt, soft-delete).
class StudentSkillRating {
  final String id;
  final String studentSessionId;
  final String skillId;
  final int value; // 1..5

  /// When the session occurred — drives recency weighting in skill-score calc.
  final DateTime recordedAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const StudentSkillRating({
    required this.id,
    required this.studentSessionId,
    required this.skillId,
    required this.value,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
