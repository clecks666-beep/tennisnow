import 'badge.dart';
import 'gamification_snapshot.dart';
import '../../../shared/domain/avatar/avatar_catalog.dart';

/// What the player just earned, computed by diffing the gamification snapshot
/// from before vs after a save. Pure value object (no Flutter, no I/O) so the
/// "felt" feedback is honest and testable — we only celebrate what actually
/// changed (★/§4: meaningful, never noisy or fake).
class ProgressionDelta {
  /// XP gained by this action (0 if unknown or unchanged).
  final int xpGained;

  /// The level before and after (equal when no level-up happened).
  final int previousLevel;
  final int newLevel;

  /// The player's title after the change (for the level-up headline).
  final String newTitle;

  /// Badges that flipped from locked → earned with this action.
  final List<Achievement> newlyEarnedBadges;

  /// True when this action's level-up crossed a cosmetic unlock threshold —
  /// at least one avatar option in the catalog became newly available.
  final bool unlocksAvatarStyles;

  const ProgressionDelta({
    required this.xpGained,
    required this.previousLevel,
    required this.newLevel,
    required this.newTitle,
    required this.newlyEarnedBadges,
    this.unlocksAvatarStyles = false,
  });

  bool get leveledUp => newLevel > previousLevel;

  /// True when something worth a celebratory (not just informational) moment
  /// happened: a level-up or a freshly unlocked badge.
  bool get hasCelebration => leveledUp || newlyEarnedBadges.isNotEmpty;

  /// Diff two snapshots. [before] may be null (e.g. it hadn't loaded yet); then
  /// we report no gain rather than guess — honesty over fake dopamine.
  static ProgressionDelta between(
    GamificationSnapshot? before,
    GamificationSnapshot after,
  ) {
    if (before == null) {
      return ProgressionDelta(
        xpGained: 0,
        previousLevel: after.level.level,
        newLevel: after.level.level,
        newTitle: after.level.title,
        newlyEarnedBadges: const [],
      );
    }

    final earnedBefore = {
      for (final a in before.achievements)
        if (a.earned) a.badge.id,
    };
    final newlyEarned = [
      for (final a in after.achievements)
        if (a.earned && !earnedBefore.contains(a.badge.id)) a,
    ];

    final prevLevel = before.level.level;
    final nextLevel = after.level.level;
    final unlocksAvatarStyles = nextLevel > prevLevel &&
        [
          ...AvatarCatalog.skinColors,
          ...AvatarCatalog.hairStyles,
          ...AvatarCatalog.hairColors,
          ...AvatarCatalog.eyeStyles,
          ...AvatarCatalog.mouthStyles,
          ...AvatarCatalog.bgColors,
        ].any((o) => o.unlockLevel > prevLevel && o.unlockLevel <= nextLevel);

    return ProgressionDelta(
      xpGained: after.totalXp - before.totalXp,
      previousLevel: prevLevel,
      newLevel: nextLevel,
      newTitle: after.level.title,
      newlyEarnedBadges: newlyEarned,
      unlocksAvatarStyles: unlocksAvatarStyles,
    );
  }
}
