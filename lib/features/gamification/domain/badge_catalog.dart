import 'badge.dart';
import 'gamification_snapshot.dart';

/// The curated, intentionally small set of badges. Lightweight and meaningful
/// (memory.md.txt: gamification must never feel gimmicky). To add a badge, add a
/// definition here and an icon mapping in the presentation layer — nothing else.
class BadgeCatalog {
  BadgeCatalog._();

  static const List<BadgeDefinition> all = [
    BadgeDefinition(
      id: 'first_session',
      title: 'First Serve',
      description: 'Log your first session',
      metric: BadgeMetric.totalSessions,
      threshold: 1,
    ),
    BadgeDefinition(
      id: 'ten_sessions',
      title: 'Regular',
      description: 'Log 10 sessions',
      metric: BadgeMetric.totalSessions,
      threshold: 10,
    ),
    BadgeDefinition(
      id: 'fifty_sessions',
      title: 'Dedicated',
      description: 'Log 50 sessions',
      metric: BadgeMetric.totalSessions,
      threshold: 50,
    ),
    BadgeDefinition(
      id: 'streak_3',
      title: 'On a Roll',
      description: 'Play 3 days in a row',
      metric: BadgeMetric.streakDays,
      threshold: 3,
    ),
    BadgeDefinition(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Play 7 days in a row',
      metric: BadgeMetric.streakDays,
      threshold: 7,
    ),
    BadgeDefinition(
      id: 'first_win',
      title: 'First Win',
      description: 'Win your first match',
      metric: BadgeMetric.wins,
      threshold: 1,
    ),
    BadgeDefinition(
      id: 'ten_matches',
      title: 'Competitor',
      description: 'Play 10 matches',
      metric: BadgeMetric.matches,
      threshold: 10,
    ),
    BadgeDefinition(
      id: 'ten_wins',
      title: 'Closer',
      description: 'Win 10 matches',
      metric: BadgeMetric.wins,
      threshold: 10,
    ),
  ];

  /// Evaluates every badge against the inputs, preserving catalog order.
  static List<Achievement> evaluate(GamificationInputs inputs) {
    return all
        .map(
          (badge) => Achievement(
            badge: badge,
            currentValue: inputs.valueFor(badge.metric),
          ),
        )
        .toList();
  }
}
