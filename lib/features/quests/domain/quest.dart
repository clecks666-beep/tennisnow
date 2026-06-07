/// Pure domain types for weekly quests — short, optional focus goals that give
/// the player a fresh reason to log each week (★C: Quests / Challenges). Like
/// the rest of progression scoring, this layer is Flutter-free, I/O-free and
/// deterministic, so a server could recompute the exact same board later
/// (CLAUDE.md §2 community-ready invariant).
///
/// Quests are DERIVED, never stored: a quest's progress is computed live from
/// the player's real sessions and skill tags. Completing one isn't a separate
/// pile of points — it simply means you did the logging that already levels you
/// up, so progression stays honest and un-farmable (★D).
library;

/// What a weekly quest measures. Each metric maps to a pure counting rule over
/// the current week's [QuestSessionInput]s / [QuestSkillInput]s.
enum QuestMetric {
  /// Number of sessions logged this week.
  sessionsThisWeek,

  /// Sessions this week that tagged a specific [WeeklyQuest.skillId].
  skillFocusThisWeek,

  /// Sessions this week that recorded how the player felt (mood or energy).
  feelingSessionsThisWeek,
}

/// A single weekly quest definition. Ids are stable, community-facing keys
/// (never renumber them). The skill-focus quest keeps a stable [id] even though
/// its [skillId] rotates each week — the quest "this week's focus skill" is the
/// stable thing.
class WeeklyQuest {
  final String id;
  final String title;
  final String description;
  final QuestMetric metric;
  final int target;

  /// Only set for [QuestMetric.skillFocusThisWeek] — the skill in focus.
  final String? skillId;

  const WeeklyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    this.skillId,
  });
}

/// A quest paired with the player's current value for it. Progress/completion
/// are derived, never persisted.
class QuestProgress {
  final WeeklyQuest quest;
  final int current;

  const QuestProgress({required this.quest, required this.current});

  int get target => quest.target;

  bool get isComplete => current >= quest.target;

  /// Remaining steps to completion, never negative.
  int get remaining => (quest.target - current).clamp(0, quest.target);

  /// 0..1 fill for a progress bar (goal-gradient: visible momentum).
  double get fraction =>
      quest.target == 0 ? 1 : (current / quest.target).clamp(0, 1).toDouble();
}

/// The player's quest board for one week: the active quests with live progress,
/// plus the week window they cover.
class WeeklyQuestBoard {
  final DateTime weekStart; // inclusive (local Monday 00:00)
  final DateTime weekEnd; // exclusive (next Monday 00:00)
  final List<QuestProgress> items;

  const WeeklyQuestBoard({
    required this.weekStart,
    required this.weekEnd,
    required this.items,
  });

  int get total => items.length;

  int get completedCount => items.where((q) => q.isComplete).length;

  bool get allComplete => items.isNotEmpty && completedCount == total;
}

/// Minimal, feature-neutral carrier for a session, so the pure evaluator never
/// imports a DB row or another feature's entity (CLAUDE.md §2). The data layer
/// maps Drift rows into these.
class QuestSessionInput {
  final String id;
  final DateTime playedAt;

  /// True if the player logged mood or energy on this session.
  final bool hasFeeling;

  const QuestSessionInput({
    required this.id,
    required this.playedAt,
    required this.hasFeeling,
  });
}

/// Minimal carrier for a per-session skill tag (which skill, on which session).
class QuestSkillInput {
  final String sessionId;
  final String skillId;

  const QuestSkillInput({required this.sessionId, required this.skillId});
}
