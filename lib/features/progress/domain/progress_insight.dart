import 'session_stats.dart';

/// Derives a short, honest, motivating headline from the stats. Pure function so
/// it is trivially testable and carries no UI concerns (CLAUDE.md §2).
///
/// Tone follows memory.md.txt: motivating but never gimmicky. It states only
/// what the data supports and nudges the user toward the next logging action.
class ProgressInsight {
  ProgressInsight._();

  static String headline(SessionStats stats) {
    if (stats.isEmpty) {
      return 'Log a few sessions to unlock your trends.';
    }

    final winRate = stats.winRate;
    if (winRate != null && stats.ratedMatchCount >= 3) {
      final pct = (winRate * 100).round();
      return 'You\'re winning $pct% of your matches — keep it rolling.';
    }

    final avg = stats.avgPerformance;
    if (avg != null) {
      return 'Your average performance is ${avg.toStringAsFixed(1)}/5. '
          'Log more to see what lifts it.';
    }

    final count = stats.totalSessions;
    final noun = count == 1 ? 'session' : 'sessions';
    return '$count $noun logged. Add a performance rating to start your trend.';
  }
}
