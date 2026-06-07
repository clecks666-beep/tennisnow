import '../../../shared/data/app_database.dart';
import '../domain/skill_self_rating.dart';

/// Maps the Drift row (`SkillRating`) to the domain entity (`SkillSelfRating`),
/// keeping persistence types out of the domain (CLAUDE.md §2).
class SkillRatingMapper {
  SkillRatingMapper._();

  static SkillSelfRating toDomain(SkillRating row) {
    return SkillSelfRating(
      id: row.id,
      sessionId: row.sessionId,
      skillId: row.skillId,
      value: row.value,
      recordedAt: row.recordedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
