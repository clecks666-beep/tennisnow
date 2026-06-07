import 'package:flutter/material.dart';

/// Returns the raster asset path for a badge id, or null when no custom
/// image exists for that id (caller falls back to [badgeIconFor]).
/// Add an entry here when a new badge PNG is placed in
/// assets/images/brand/badges/.
String? badgeAssetFor(String badgeId) {
  const assets = <String, String>{
    'first_session': 'assets/images/brand/badges/badge_first_session.png',
    'ten_sessions': 'assets/images/brand/badges/badge_ten_sessions.png',
    'streak_3': 'assets/images/brand/badges/badge_streak_3.png',
    'streak_7': 'assets/images/brand/badges/badge_streak_7.png',
    'first_win': 'assets/images/brand/badges/badge_first_win.png',
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
    case 'streak_3':
      return Icons.local_fire_department_rounded;
    case 'streak_7':
      return Icons.whatshot_rounded;
    case 'first_win':
      return Icons.emoji_events_rounded;
    case 'ten_matches':
      return Icons.sports_rounded;
    case 'ten_wins':
      return Icons.military_tech_rounded;
    default:
      return Icons.emoji_events_outlined;
  }
}
