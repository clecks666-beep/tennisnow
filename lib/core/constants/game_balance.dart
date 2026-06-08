/// Single source of truth for gamification balancing (CLAUDE.md §3: game
/// constants are centralized, never scattered literals; ★ section).
///
/// All progression scoring built on these is PURE and DETERMINISTIC so a server
/// could one day recompute/verify the same numbers (community-ready, ADR-007).
class GameBalance {
  GameBalance._();

  // ---- XP awards (cumulative, honest, monotonic) ----
  // XP derives from facts that never decrease, so a player's XP/level can only
  // go up. Completeness/skill-work bonuses are added when skill capture lands.
  static const int xpPerSession = 10; // every logged session
  static const int xpPerMatch = 5; // extra for a match (vs training)
  static const int xpPerWin = 5; // extra for a won match

  /// Bonus for a session in which the player tagged the skills they worked on
  /// (the optional skill capture). Awarded PER SESSION, not per rating, so it
  /// rewards engaging with the skill model without being farmable by rating many
  /// skills at once (★C "bonus for working a focus skill"; honest, non-gameable).
  static const int xpPerSkillSession = 5;

  // ---- Level curve ----
  // XP needed to advance FROM level L to L+1 grows linearly:
  //   step(L) = levelBaseStep + (L-1) * levelStepIncrement
  static const int levelBaseStep = 100;
  static const int levelStepIncrement = 50;

  /// Half-life (days) for recency-weighting skill self-ratings: a rating this
  /// many days old counts half as much as a fresh one, so a SkillScore reflects
  /// current form (★ section: recency-weighted skill ratings).
  static const double skillRecencyHalfLifeDays = 30;

  /// Titles by minimum level, highest first. Looked up top-down.
  /// Cosmetic-tier levels (3/6/10/15) keep their title so an avatar unlock
  /// coincides narratively with the new title (both fire on the same level-up).
  static const List<({int minLevel, String title})> levelTitles = [
    (minLevel: 25, title: 'Pro-Am'),
    (minLevel: 20, title: 'District Champion'),
    (minLevel: 18, title: 'Elite'),
    (minLevel: 15, title: 'Ace'),              // cosmeticTierAce
    (minLevel: 13, title: 'Tournament Player'),
    (minLevel: 10, title: 'Challenger'),       // cosmeticTierChallenger
    (minLevel: 8, title: 'League Player'),
    (minLevel: 6, title: 'Club Contender'),    // cosmeticTierContender
    (minLevel: 5, title: 'Club Player'),
    (minLevel: 3, title: 'Rallyer'),           // cosmeticTierRallyer
    (minLevel: 2, title: 'Club Regular'),
    (minLevel: 1, title: 'Rookie'),
  ];

  // ---- Cosmetic unlock tiers (avatar customisation) ----
  // Avatar options are gated by player level so cosmetics become an honest,
  // earned reward (★C/D). Tiers align with the title ladder above so an unlock
  // narratively coincides with "becoming a Rallyer / Club Contender / …".
  // Because level is derived from monotonic XP, an unlock is permanent without
  // persisting anything — gating stays fully derived-not-stored & community-
  // ready. NOTE: identity options (skin tones) are NEVER gated — only styles,
  // expressions, fun hair colours and premium backgrounds.
  static const int cosmeticTierStart = 1; // available from the first session
  static const int cosmeticTierRallyer = 3;
  static const int cosmeticTierContender = 6;
  static const int cosmeticTierChallenger = 10;
  static const int cosmeticTierAce = 15;
}
