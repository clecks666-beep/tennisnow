import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/gamification/domain/streak_calculator.dart';

void main() {
  final today = DateTime(2026, 6, 6, 18, 0);
  DateTime daysAgo(int n) => DateTime(2026, 6, 6).subtract(Duration(days: n));

  group('StreakCalculator', () {
    test('no sessions => empty streak', () {
      final s = StreakCalculator.compute([], today);
      expect(s.current, 0);
      expect(s.longest, 0);
      expect(s.activeToday, isFalse);
    });

    test('counts consecutive days ending today', () {
      final s = StreakCalculator.compute(
        [daysAgo(0), daysAgo(1), daysAgo(2)],
        today,
      );
      expect(s.current, 3);
      expect(s.activeToday, isTrue);
    });

    test('ignores multiple sessions on the same day', () {
      final s = StreakCalculator.compute(
        [
          DateTime(2026, 6, 6, 9),
          DateTime(2026, 6, 6, 19),
          daysAgo(1),
        ],
        today,
      );
      expect(s.current, 2);
    });

    test('grace day: not logged today but logged yesterday keeps streak', () {
      final s = StreakCalculator.compute([daysAgo(1), daysAgo(2)], today);
      expect(s.current, 2);
      expect(s.activeToday, isFalse);
    });

    test('a gap breaks the current streak', () {
      final s = StreakCalculator.compute([daysAgo(0), daysAgo(2), daysAgo(3)], today);
      expect(s.current, 1); // only today is consecutive
    });

    test('longest run is found across history', () {
      final s = StreakCalculator.compute(
        [daysAgo(0), daysAgo(5), daysAgo(6), daysAgo(7), daysAgo(8)],
        today,
      );
      expect(s.longest, 4); // the 5..8 days-ago run
      expect(s.current, 1);
    });

    test('stale data: last session days ago => current 0, longest preserved', () {
      final s = StreakCalculator.compute([daysAgo(10), daysAgo(11)], today);
      expect(s.current, 0);
      expect(s.longest, 2);
    });
  });
}
