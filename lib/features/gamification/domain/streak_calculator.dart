import 'streak.dart';

/// Computes a daily logging [Streak] from session timestamps. Pure and
/// deterministic (takes `today` explicitly) so it is trivially unit-testable.
///
/// This is the date-window logic deliberately deferred earlier (see
/// memory.md.txt): consecutive-day streaks are sequential and awkward in
/// portable SQL, so we compute them here in Dart over the (personal-scale) set
/// of distinct played days.
class StreakCalculator {
  StreakCalculator._();

  static Streak compute(List<DateTime> playedAt, DateTime today) {
    if (playedAt.isEmpty) return Streak.none;

    // Reduce to the set of distinct calendar days (ignore time of day).
    final days = <DateTime>{
      for (final d in playedAt) DateTime(d.year, d.month, d.day),
    };

    final todayDay = DateTime(today.year, today.month, today.day);
    final yesterday = todayDay.subtract(const Duration(days: 1));
    final activeToday = days.contains(todayDay);

    // Current streak anchors at today if logged, else yesterday (grace day).
    DateTime? anchor;
    if (activeToday) {
      anchor = todayDay;
    } else if (days.contains(yesterday)) {
      anchor = yesterday;
    }

    var current = 0;
    if (anchor != null) {
      var cursor = anchor;
      while (days.contains(cursor)) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    return Streak(
      current: current,
      longest: _longestRun(days),
      activeToday: activeToday,
    );
  }

  /// Longest run of consecutive days across all logged days.
  static int _longestRun(Set<DateTime> days) {
    final sorted = days.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inDays;
      if (gap == 1) {
        run++;
        if (run > best) best = run;
      } else if (gap > 1) {
        run = 1;
      }
      // gap == 0 cannot happen because days is a set of date-only values.
    }
    return best;
  }
}
