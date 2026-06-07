import '../../../core/constants/game_balance.dart';

/// Pure, deterministic XP scoring (★ section / ADR-007). Same inputs always
/// yield the same XP, so a server could recompute it — no client-only trust.
///
/// XP is derived from cumulative facts (sessions, matches, wins, skill-tagged
/// sessions). It never decreases as the player adds activity, and every term is
/// a count the data layer reads in SQL — so a server could recompute the exact
/// same XP (community-ready).
///
/// [skillSessions] is the number of sessions in which the player tagged the
/// skills they worked on; each grants [GameBalance.xpPerSkillSession]. Counting
/// sessions (not individual ratings) keeps the bonus honest and non-farmable.
class XpRules {
  XpRules._();

  static int totalXp({
    required int sessions,
    required int matches,
    required int wins,
    int skillSessions = 0,
  }) {
    return sessions * GameBalance.xpPerSession +
        matches * GameBalance.xpPerMatch +
        wins * GameBalance.xpPerWin +
        skillSessions * GameBalance.xpPerSkillSession;
  }
}
