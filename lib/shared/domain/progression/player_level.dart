import '../../../core/constants/game_balance.dart';

/// The player's level derived from total XP. Pure value object computed by a
/// deterministic function (★ section / ADR-007) so it is testable and
/// server-recomputable. Never store the level as an opaque number — always
/// re-derive it from XP via [forXp].
class PlayerLevel {
  final int level;
  final String title;
  final int totalXp;

  /// XP accumulated within the current level.
  final int xpIntoLevel;

  /// XP span of the current level (XP needed to reach the next one).
  final int xpForNextLevel;

  const PlayerLevel({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// 0..1 progress toward the next level.
  double get progress =>
      xpForNextLevel == 0 ? 0 : (xpIntoLevel / xpForNextLevel).clamp(0, 1);

  /// XP still needed to reach the next level.
  int get xpToNextLevel => (xpForNextLevel - xpIntoLevel).clamp(0, xpForNextLevel);

  static PlayerLevel forXp(int xp) {
    final total = xp < 0 ? 0 : xp;
    var level = 1;
    var consumed = 0; // XP consumed to reach the start of `level`
    while (true) {
      final step =
          GameBalance.levelBaseStep + (level - 1) * GameBalance.levelStepIncrement;
      if (total - consumed < step) {
        return PlayerLevel(
          level: level,
          title: _titleFor(level),
          totalXp: total,
          xpIntoLevel: total - consumed,
          xpForNextLevel: step,
        );
      }
      consumed += step;
      level++;
    }
  }

  static String _titleFor(int level) {
    for (final entry in GameBalance.levelTitles) {
      if (level >= entry.minLevel) return entry.title;
    }
    return GameBalance.levelTitles.last.title;
  }
}
