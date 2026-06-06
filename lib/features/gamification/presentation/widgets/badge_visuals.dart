import 'package:flutter/material.dart';

/// Maps a badge id to its icon. Lives in presentation so the domain stays
/// Flutter-free (CLAUDE.md §2). Add a mapping here when adding a badge to the
/// catalog; unknown ids fall back to a generic medal.
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
