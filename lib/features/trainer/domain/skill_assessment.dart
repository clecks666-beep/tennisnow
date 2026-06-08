/// A trainer's skill assessment for a student at a point in time. Uses the same
/// [skillId] vocabulary as [SkillCatalog] from shared/domain/skill so trainer
/// ratings and student self-ratings share one taxonomy (★B, CLAUDE.md).
class SkillAssessment {
  final String id;
  final String studentId;
  final String skillId; // stable id from SkillCatalog
  final int rating; // 1-5
  final String? notes;
  final DateTime assessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SkillAssessment({
    required this.id,
    required this.studentId,
    required this.skillId,
    required this.rating,
    this.notes,
    required this.assessedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
