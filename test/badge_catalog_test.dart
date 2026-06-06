import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/gamification/domain/badge_catalog.dart';
import 'package:tennisnow/features/gamification/domain/gamification_snapshot.dart';

void main() {
  group('BadgeCatalog.evaluate', () {
    test('nothing earned at zero', () {
      final achievements = BadgeCatalog.evaluate(
        const GamificationInputs(
          totalSessions: 0,
          streakDays: 0,
          matches: 0,
          wins: 0,
        ),
      );
      expect(achievements, isNotEmpty);
      expect(achievements.where((a) => a.earned), isEmpty);
    });

    test('earns the right badges for given inputs', () {
      final achievements = BadgeCatalog.evaluate(
        const GamificationInputs(
          totalSessions: 12,
          streakDays: 4,
          matches: 10,
          wins: 2,
        ),
      );
      final earnedIds =
          achievements.where((a) => a.earned).map((a) => a.badge.id).toSet();
      expect(earnedIds, contains('first_session'));
      expect(earnedIds, contains('ten_sessions'));
      expect(earnedIds, contains('streak_3'));
      expect(earnedIds, contains('first_win'));
      expect(earnedIds, contains('ten_matches'));
      expect(earnedIds, isNot(contains('fifty_sessions')));
      expect(earnedIds, isNot(contains('streak_7')));
      expect(earnedIds, isNot(contains('ten_wins')));
    });

    test('progress is clamped to 0..1', () {
      final achievements = BadgeCatalog.evaluate(
        const GamificationInputs(
          totalSessions: 999,
          streakDays: 0,
          matches: 0,
          wins: 0,
        ),
      );
      for (final a in achievements) {
        expect(a.progress, inInclusiveRange(0, 1));
      }
    });
  });
}
