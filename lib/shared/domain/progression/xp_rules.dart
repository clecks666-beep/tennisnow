import '../../../core/constants/game_balance.dart';

/// Pure, deterministic XP scoring (★ section / ADR-007). Same inputs always
/// yield the same XP, so a server could recompute it — no client-only trust.
///
/// XP is derived from cumulative, monotonic facts (sessions, matches, wins) so
/// it never decreases. Completeness / skill-work bonuses join later without
/// breaking determinism.
class XpRules {
  XpRules._();

  static int totalXp({
    required int sessions,
    required int matches,
    required int wins,
  }) {
    return sessions * GameBalance.xpPerSession +
        matches * GameBalance.xpPerMatch +
        wins * GameBalance.xpPerWin;
  }
}
