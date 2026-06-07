import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/shared/domain/progression/player_level.dart';
import 'package:tennisnow/shared/domain/progression/xp_rules.dart';

void main() {
  group('XpRules.totalXp', () {
    test('is zero with no activity', () {
      expect(XpRules.totalXp(sessions: 0, matches: 0, wins: 0), 0);
    });

    test('sums session, match and win awards', () {
      // 3*10 + 2*5 + 1*5 = 45
      expect(XpRules.totalXp(sessions: 3, matches: 2, wins: 1), 45);
    });

    test('is monotonic in every input', () {
      final base = XpRules.totalXp(sessions: 5, matches: 2, wins: 1);
      expect(XpRules.totalXp(sessions: 6, matches: 2, wins: 1), greaterThan(base));
      expect(XpRules.totalXp(sessions: 5, matches: 3, wins: 1), greaterThan(base));
      expect(XpRules.totalXp(sessions: 5, matches: 2, wins: 2), greaterThan(base));
    });

    test('skill-tagged sessions add a bonus (default 0)', () {
      final base = XpRules.totalXp(sessions: 5, matches: 2, wins: 1);
      // 5*10 + 2*5 + 1*5 = 65; +2 skill sessions * 5 = 75
      expect(
        XpRules.totalXp(sessions: 5, matches: 2, wins: 1, skillSessions: 2),
        base + 10,
      );
      // Omitting skillSessions must keep prior behavior (no implicit bonus).
      expect(XpRules.totalXp(sessions: 5, matches: 2, wins: 1), base);
    });

    test('skill bonus is monotonic too', () {
      final base = XpRules.totalXp(sessions: 3, matches: 0, wins: 0, skillSessions: 1);
      expect(
        XpRules.totalXp(sessions: 3, matches: 0, wins: 0, skillSessions: 2),
        greaterThan(base),
      );
    });
  });

  group('PlayerLevel.forXp', () {
    test('level 1 at zero XP', () {
      final l = PlayerLevel.forXp(0);
      expect(l.level, 1);
      expect(l.title, 'Rookie');
      expect(l.xpIntoLevel, 0);
      expect(l.xpForNextLevel, 100);
      expect(l.progress, 0);
    });

    test('progresses within a level', () {
      final l = PlayerLevel.forXp(50);
      expect(l.level, 1);
      expect(l.xpIntoLevel, 50);
      expect(l.progress, closeTo(0.5, 1e-9));
      expect(l.xpToNextLevel, 50);
    });

    test('crosses into level 2 at 100 XP (step grows)', () {
      final l = PlayerLevel.forXp(100);
      expect(l.level, 2);
      expect(l.xpIntoLevel, 0);
      expect(l.xpForNextLevel, 150); // 100 + 50
    });

    test('reaches level 3 at 250 XP and earns a new title', () {
      final l = PlayerLevel.forXp(250); // 100 (L1) + 150 (L2)
      expect(l.level, 3);
      expect(l.title, 'Rallyer');
      expect(l.xpForNextLevel, 200);
    });

    test('is deterministic and total XP is preserved', () {
      expect(PlayerLevel.forXp(123).totalXp, 123);
      expect(PlayerLevel.forXp(123).level, PlayerLevel.forXp(123).level);
    });

    test('clamps negative XP to level 1', () {
      expect(PlayerLevel.forXp(-10).level, 1);
      expect(PlayerLevel.forXp(-10).totalXp, 0);
    });
  });
}
