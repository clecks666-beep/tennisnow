import '../../../shared/domain/skill/skill_catalog.dart';
import 'quest.dart';

/// The weekly-quest engine: ONE pure source of truth that both defines the
/// week's quests and evaluates the player's progress against them — the same
/// catalog + pure-function shape as BadgeCatalog / StreakCalculator (CLAUDE.md
/// §3 "reuse the catalog/pure-function pattern, don't invent a parallel one").
///
/// Everything here is deterministic given ([now], sessions, skill tags): same
/// input → same board, so it's testable and server-recomputable. The quest set
/// is deliberately small, achievable and inclusive (no match requirement, so a
/// training-only hobby player can complete every quest) — motivating, never
/// nagging (★D / §4).
class WeeklyQuests {
  WeeklyQuests._();

  /// Curated rotation for the weekly "skill focus" quest. Recognisable strokes
  /// first so the goal feels like real tennis. Rotates deterministically by
  /// week, giving a fresh focus every Monday (fresh-start effect) without any
  /// stored state. Ids must exist in [SkillCatalog].
  static const List<String> focusSkillRotation = [
    'backhand',
    'forehand',
    'serve',
    'volley',
    'return',
    'slice',
    'spin',
    'consistency',
  ];

  /// A fixed reference Monday (2024-01-01 was a Monday) used only to derive a
  /// stable, monotonic week index for the rotation. Not a user-facing date.
  static final DateTime _epochMonday = DateTime(2024, 1, 1);

  /// Builds the live quest board for the week containing [now].
  static WeeklyQuestBoard boardFor(
    DateTime now,
    List<QuestSessionInput> sessions,
    List<QuestSkillInput> skillTags,
  ) {
    final weekStart = _weekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    bool inWeek(DateTime d) => !d.isBefore(weekStart) && d.isBefore(weekEnd);

    final weekSessions = sessions.where((s) => inWeek(s.playedAt)).toList();
    final weekSessionIds = weekSessions.map((s) => s.id).toSet();

    final sessionCount = weekSessions.length;
    final feelingCount = weekSessions.where((s) => s.hasFeeling).length;

    final focusSkillId = _focusSkillFor(weekStart);
    // Distinct in-week sessions that tagged the focus skill.
    final focusSessions = skillTags
        .where((t) =>
            t.skillId == focusSkillId && weekSessionIds.contains(t.sessionId))
        .map((t) => t.sessionId)
        .toSet()
        .length;

    final focusName = SkillCatalog.byId(focusSkillId)?.name ?? 'a skill';

    final quests = <QuestProgress>[
      QuestProgress(
        current: sessionCount,
        quest: const WeeklyQuest(
          id: 'weekly_rhythm',
          title: 'Weekly rhythm',
          description: 'Log 3 sessions this week',
          metric: QuestMetric.sessionsThisWeek,
          target: 3,
        ),
      ),
      QuestProgress(
        current: focusSessions,
        quest: WeeklyQuest(
          id: 'weekly_skill_focus',
          title: 'Focus: $focusName',
          description: 'Work on your $focusName in 2 sessions this week',
          metric: QuestMetric.skillFocusThisWeek,
          target: 2,
          skillId: focusSkillId,
        ),
      ),
      QuestProgress(
        current: feelingCount,
        quest: const WeeklyQuest(
          id: 'weekly_tune_in',
          title: 'Tune in',
          description: 'Note your mood or energy in 2 sessions this week',
          metric: QuestMetric.feelingSessionsThisWeek,
          target: 2,
        ),
      ),
    ];

    return WeeklyQuestBoard(
      weekStart: weekStart,
      weekEnd: weekEnd,
      items: quests,
    );
  }

  /// Local Monday 00:00 of the week containing [now] (ISO weeks start Monday).
  static DateTime _weekStart(DateTime now) {
    final midnight = DateTime(now.year, now.month, now.day);
    // DateTime.weekday: Monday = 1 … Sunday = 7.
    return midnight.subtract(Duration(days: midnight.weekday - 1));
  }

  /// Deterministic focus skill for the given week start.
  static String _focusSkillFor(DateTime weekStart) {
    final weeks = weekStart.difference(_epochMonday).inDays ~/ 7;
    // Guard against negative indices for dates before the reference Monday.
    final index = weeks % focusSkillRotation.length;
    final safeIndex = index < 0 ? index + focusSkillRotation.length : index;
    return focusSkillRotation[safeIndex];
  }
}
