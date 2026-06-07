/// A single skill self-rating event — "I worked on my serve this session, felt
/// 4/5". Pure domain entity with the sync-ready invariant. Owned by a session.
class SkillSelfRating {
  final String id;
  final String sessionId;
  final String skillId;
  final int value; // 1..5

  /// When the rated play happened (the session's date) — drives recency.
  final DateTime recordedAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SkillSelfRating({
    required this.id,
    required this.sessionId,
    required this.skillId,
    required this.value,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}
