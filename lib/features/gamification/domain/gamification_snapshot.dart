import '../../../shared/domain/progression/player_level.dart';
import 'badge.dart';
import 'streak.dart';

/// The raw numbers badges are evaluated against. Assembled in the data layer
/// from existing session aggregates + streak — no new persistence.
class GamificationInputs {
  final int totalSessions;
  final int streakDays;
  final int matches;
  final int wins;

  const GamificationInputs({
    required this.totalSessions,
    required this.streakDays,
    required this.matches,
    required this.wins,
  });

  int valueFor(BadgeMetric metric) {
    switch (metric) {
      case BadgeMetric.totalSessions:
        return totalSessions;
      case BadgeMetric.streakDays:
        return streakDays;
      case BadgeMetric.matches:
        return matches;
      case BadgeMetric.wins:
        return wins;
    }
  }
}

/// Everything the motivation UI needs in one immutable snapshot — the seed of
/// the Player Profile (★ section): level/XP + streak + badges.
class GamificationSnapshot {
  final PlayerLevel level;
  final Streak streak;
  final List<Achievement> achievements;

  const GamificationSnapshot({
    required this.level,
    required this.streak,
    required this.achievements,
  });

  int get totalXp => level.totalXp;

  int get earnedCount => achievements.where((a) => a.earned).length;

  /// The closest not-yet-earned badge (highest progress), or null if all earned.
  Achievement? get nextUp {
    Achievement? best;
    for (final a in achievements) {
      if (a.earned) continue;
      if (best == null || a.progress > best.progress) best = a;
    }
    return best;
  }
}
