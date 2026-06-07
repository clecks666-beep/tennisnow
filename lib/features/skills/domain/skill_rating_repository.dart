import 'skill_self_rating.dart';

/// Domain contract for skill self-ratings. The UI depends on this interface
/// only — never on Drift (CLAUDE.md §2).
abstract interface class SkillRatingRepository {
  /// Live stream of active skill ratings (excludes those of deleted sessions).
  Stream<List<SkillSelfRating>> watchActive();

  /// The skill→value map currently recorded for a session (for edit prefill).
  Future<Map<String, int>> ratingsForSession(String sessionId);

  /// Replaces a session's skill ratings with [skillValues] (skillId→1..5),
  /// stamping them at [recordedAt] (the session's date). Empty clears them.
  Future<void> replaceForSession(
    String sessionId,
    DateTime recordedAt,
    Map<String, int> skillValues,
  );
}
