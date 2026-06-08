import 'badge.dart';
import 'gamification_snapshot.dart';

/// The curated badge set. Lightweight and meaningful (memory.md.txt: gamification
/// must never feel gimmicky). To add a badge, add a definition here and an icon
/// mapping in badge_visuals.dart — nothing else to wire.
class BadgeCatalog {
  BadgeCatalog._();

  static const List<BadgeDefinition> all = [
    // ── Volume ────────────────────────────────────────────────────────────────
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
      rarity: BadgeRarity.rare,
    ),
    BadgeDefinition(
      id: 'hundred_sessions',
      title: 'Centurion',
      description: 'Log 100 sessions',
      metric: BadgeMetric.totalSessions,
      threshold: 100,
      rarity: BadgeRarity.epic,
    ),
    BadgeDefinition(
      id: 'two_hundred_sessions',
      title: 'Ironclad',
      description: 'Log 200 sessions',
      metric: BadgeMetric.totalSessions,
      threshold: 200,
      rarity: BadgeRarity.legendary,
    ),

    // ── Streaks ────────────────────────────────────────────────────────────────
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
      rarity: BadgeRarity.rare,
    ),
    BadgeDefinition(
      id: 'streak_14',
      title: 'Fortnight',
      description: 'Play 14 days in a row',
      metric: BadgeMetric.streakDays,
      threshold: 14,
      rarity: BadgeRarity.epic,
    ),
    BadgeDefinition(
      id: 'streak_30',
      title: 'Unstoppable',
      description: 'Play 30 days in a row',
      metric: BadgeMetric.streakDays,
      threshold: 30,
      rarity: BadgeRarity.legendary,
    ),

    // ── Matches ────────────────────────────────────────────────────────────────
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
      rarity: BadgeRarity.rare,
    ),
    BadgeDefinition(
      id: 'fifty_matches',
      title: 'Match Machine',
      description: 'Play 50 matches',
      metric: BadgeMetric.matches,
      threshold: 50,
      rarity: BadgeRarity.epic,
    ),
    BadgeDefinition(
      id: 'hundred_wins',
      title: 'Century',
      description: 'Win 100 matches',
      metric: BadgeMetric.wins,
      threshold: 100,
      rarity: BadgeRarity.legendary,
    ),

    // ── Skills ────────────────────────────────────────────────────────────────
    BadgeDefinition(
      id: 'skill_rated',
      title: 'Skill Scout',
      description: 'Tag skills in a session for the first time',
      metric: BadgeMetric.skillTaggedSessions,
      threshold: 1,
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
