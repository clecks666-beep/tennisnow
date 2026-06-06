import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/progress/domain/progress_insight.dart';
import 'package:tennisnow/features/progress/domain/session_stats.dart';

void main() {
  group('SessionStats.winRate', () {
    test('is null with no rated matches', () {
      expect(SessionStats.empty.winRate, isNull);
    });

    test('is the won fraction of rated matches', () {
      const stats = SessionStats(
        totalSessions: 5,
        matchCount: 4,
        ratedMatchCount: 4,
        winCount: 3,
        avgPerformance: 3.5,
        avgMood: null,
        avgEnergy: null,
      );
      expect(stats.winRate, closeTo(0.75, 1e-9));
    });
  });

  group('ProgressInsight.headline', () {
    test('nudges first-time users when empty', () {
      expect(
        ProgressInsight.headline(SessionStats.empty),
        contains('Log a few sessions'),
      );
    });

    test('reports win rate once there are enough rated matches', () {
      const stats = SessionStats(
        totalSessions: 6,
        matchCount: 4,
        ratedMatchCount: 4,
        winCount: 2,
        avgPerformance: 3.0,
        avgMood: null,
        avgEnergy: null,
      );
      expect(ProgressInsight.headline(stats), contains('50%'));
    });

    test('falls back to average performance when matches are too few', () {
      const stats = SessionStats(
        totalSessions: 3,
        matchCount: 1,
        ratedMatchCount: 1,
        winCount: 1,
        avgPerformance: 4.2,
        avgMood: null,
        avgEnergy: null,
      );
      final headline = ProgressInsight.headline(stats);
      expect(headline, contains('4.2/5'));
    });

    test('handles sessions with no ratings yet', () {
      const stats = SessionStats(
        totalSessions: 2,
        matchCount: 0,
        ratedMatchCount: 0,
        winCount: 0,
        avgPerformance: null,
        avgMood: null,
        avgEnergy: null,
      );
      expect(ProgressInsight.headline(stats), contains('2 sessions'));
    });
  });
}
