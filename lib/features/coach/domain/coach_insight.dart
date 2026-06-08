/// Where a [CoachInsight] came from. Surfaced honestly in the UI so the player
/// is never misled about whether a real model spoke (CLAUDE.md §11 honesty /
/// explainability; §7 no fake intelligence). [rule] is the deterministic,
/// offline, zero-token coach; [ai] is a live model response.
enum CoachSource { rule, ai }

/// One coaching read: a short headline, a forward-looking body, the data it is
/// grounded in (explainability, §11), and an optional skill to focus next.
///
/// Pure value object — no Flutter, no I/O — so the same shape works whether the
/// text was computed deterministically or returned by an LLM.
class CoachInsight {
  final String headline;
  final String body;

  /// Short phrases naming what the read is based on (e.g. "12 sessions",
  /// "win rate 60%"). Drives the explainability chips in the UI.
  final List<String> basis;

  /// Skill id the coach suggests focusing on next, or null.
  final String? focusSkillId;

  final CoachSource source;

  const CoachInsight({
    required this.headline,
    required this.body,
    required this.source,
    this.basis = const [],
    this.focusSkillId,
  });
}
