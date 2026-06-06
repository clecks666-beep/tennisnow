/// The metric a badge is earned against. Maps to a value in [GamificationInputs].
enum BadgeMetric { totalSessions, streakDays, matches, wins }

/// Definition of an earnable badge. Pure data — no UI (the icon is chosen in
/// presentation by [id], keeping the domain Flutter-free, CLAUDE.md §2).
class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final BadgeMetric metric;
  final int threshold;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.threshold,
  });
}

/// A badge evaluated against the player's current numbers.
class Achievement {
  final BadgeDefinition badge;
  final int currentValue;

  const Achievement({required this.badge, required this.currentValue});

  bool get earned => currentValue >= badge.threshold;

  /// 0..1 progress toward the threshold (1.0 once earned).
  double get progress =>
      badge.threshold == 0 ? 1 : (currentValue / badge.threshold).clamp(0, 1);
}
