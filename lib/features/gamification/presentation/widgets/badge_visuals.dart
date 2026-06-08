import 'package:flutter/material.dart';

import '../../domain/badge.dart';

/// Returns the raster asset path for a badge id, or null when no custom
/// image exists for that id (caller falls back to [badgeIconFor]).
/// Add an entry here when a new badge PNG is placed in
/// assets/images/brand/badges/.
String? badgeAssetFor(String badgeId) {
  const assets = <String, String>{
    'first_session':  'assets/images/brand/badges/badge_first_session.png',
    'ten_sessions':   'assets/images/brand/badges/badge_ten_sessions.png',
    'fifty_sessions': 'assets/images/brand/badges/badge_fifty_sessions.png',
    'streak_3':       'assets/images/brand/badges/badge_streak_3.png',
    'streak_7':       'assets/images/brand/badges/badge_streak_7.png',
    'first_win':      'assets/images/brand/badges/badge_first_win.png',
    'ten_matches':    'assets/images/brand/badges/badge_ten_matches.png',
    'ten_wins':       'assets/images/brand/badges/badge_ten_wins.png',
  };
  return assets[badgeId];
}

/// Maps a badge id to its fallback icon. Used when no raster asset is
/// available for the id. Lives in presentation so the domain stays
/// Flutter-free (CLAUDE.md §2). Add a mapping here when adding a badge to
/// the catalog; unknown ids fall back to a generic medal.
IconData badgeIconFor(String badgeId) {
  switch (badgeId) {
    case 'first_session':
      return Icons.sports_tennis_rounded;
    case 'ten_sessions':
      return Icons.calendar_month_rounded;
    case 'fifty_sessions':
      return Icons.workspace_premium_rounded;
    case 'hundred_sessions':
      return Icons.verified_rounded;
    case 'two_hundred_sessions':
      return Icons.diamond_rounded;
    case 'streak_3':
      return Icons.local_fire_department_rounded;
    case 'streak_7':
      return Icons.whatshot_rounded;
    case 'streak_14':
      return Icons.bolt_rounded;
    case 'streak_30':
      return Icons.flash_on_rounded;
    case 'first_win':
      return Icons.emoji_events_rounded;
    case 'ten_matches':
      return Icons.sports_rounded;
    case 'ten_wins':
      return Icons.military_tech_rounded;
    case 'fifty_matches':
      return Icons.sports_score_rounded;
    case 'hundred_wins':
      return Icons.stars_rounded;
    case 'skill_rated':
      return Icons.auto_graph_rounded;
    default:
      return Icons.emoji_events_outlined;
  }
}

/// The accent color for a given [BadgeRarity]. Standard badges use
/// [AppColors.primary] (handled by the tile); only the elevated rarities
/// get a distinct color here.
Color rarityColor(BadgeRarity rarity) {
  switch (rarity) {
    case BadgeRarity.standard:
      return const Color(0xFF2E7D32); // AppColors.primary — court green
    case BadgeRarity.rare:
      return const Color(0xFF1565C0); // deep blue
    case BadgeRarity.epic:
      return const Color(0xFF6A1B9A); // deep purple
    case BadgeRarity.legendary:
      return const Color(0xFFF9A825); // amber gold
  }
}

/// Short display label for a rarity level. Standard returns null (no label
/// shown — keeps standard tiles uncluttered).
String? rarityLabel(BadgeRarity rarity) {
  switch (rarity) {
    case BadgeRarity.standard:
      return null;
    case BadgeRarity.rare:
      return 'Rare';
    case BadgeRarity.epic:
      return 'Epic';
    case BadgeRarity.legendary:
      return 'Legendary';
  }
}
