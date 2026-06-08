import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/gamification/domain/badge.dart';
import 'package:tennisnow/features/gamification/domain/gamification_snapshot.dart';
import 'package:tennisnow/features/gamification/domain/progression_delta.dart';
import 'package:tennisnow/features/gamification/domain/streak.dart';
import 'package:tennisnow/core/constants/game_balance.dart';
import 'package:tennisnow/shared/domain/progression/player_level.dart';

void main() {
  const badgeA = BadgeDefinition(
    id: 'first_session',
    title: 'First Session',
    description: 'Logged your first session',
    metric: BadgeMetric.totalSessions,
    threshold: 1,
  );
  const badgeB = BadgeDefinition(
    id: 'first_win',
    title: 'First Win',
    description: 'Won your first match',
    metric: BadgeMetric.wins,
    threshold: 1,
  );

  GamificationSnapshot snap(int xp, {int aValue = 0, int bValue = 0}) {
    return GamificationSnapshot(
      level: PlayerLevel.forXp(xp),
      streak: Streak.none,
      achievements: [
        Achievement(badge: badgeA, currentValue: aValue),
        Achievement(badge: badgeB, currentValue: bValue),
      ],
    );
  }

  group('ProgressionDelta.between', () {
    test('null baseline -> no gain, no celebration (honest fallback)', () {
      final d = ProgressionDelta.between(null, snap(120, aValue: 1));
      expect(d.xpGained, 0);
      expect(d.leveledUp, isFalse);
      expect(d.newlyEarnedBadges, isEmpty);
      expect(d.hasCelebration, isFalse);
    });

    test('reports XP gained within the same level', () {
      final d = ProgressionDelta.between(snap(10), snap(25));
      expect(d.xpGained, 15);
      expect(d.leveledUp, isFalse);
      expect(d.hasCelebration, isFalse);
    });

    test('detects a level-up', () {
      // Level 1 spans 0..99; 100 crosses into level 2.
      final d = ProgressionDelta.between(snap(90), snap(110));
      expect(d.leveledUp, isTrue);
      expect(d.previousLevel, 1);
      expect(d.newLevel, 2);
      expect(d.xpGained, 20);
      expect(d.hasCelebration, isTrue);
    });

    test('detects only NEWLY earned badges', () {
      // badgeA already earned before; badgeB becomes earned now.
      final before = snap(40, aValue: 1, bValue: 0);
      final after = snap(50, aValue: 1, bValue: 1);
      final d = ProgressionDelta.between(before, after);
      expect(d.newlyEarnedBadges.map((a) => a.badge.id), ['first_win']);
      expect(d.hasCelebration, isTrue);
    });

    test('already-earned badges do not re-trigger', () {
      final before = snap(40, aValue: 1, bValue: 1);
      final after = snap(50, aValue: 1, bValue: 1);
      final d = ProgressionDelta.between(before, after);
      expect(d.newlyEarnedBadges, isEmpty);
      expect(d.hasCelebration, isFalse);
    });
  });

  group('ProgressionDelta.unlocksAvatarStyles', () {
    // Level thresholds (step(L) = 100 + (L-1)*50):
    //   Lv1: 0..99  Lv2: 100..249  Lv3: 250..449
    //   cosmeticTierRallyer = 3, cosmeticTierContender = 6

    test('false when no level-up', () {
      final d = ProgressionDelta.between(snap(10), snap(25));
      expect(d.unlocksAvatarStyles, isFalse);
    });

    test('false for level-up that does not cross a cosmetic tier (lv1→lv2)', () {
      final d = ProgressionDelta.between(snap(90), snap(110));
      expect(d.previousLevel, 1);
      expect(d.newLevel, 2);
      expect(d.unlocksAvatarStyles, isFalse);
    });

    test('true when crossing cosmeticTierRallyer (lv2→lv3)', () {
      // snap(240) = lv2, snap(260) = lv3 = cosmeticTierRallyer
      final before = snap(240);
      final after = snap(260);
      expect(before.level.level, 2);
      expect(after.level.level, GameBalance.cosmeticTierRallyer);
      final d = ProgressionDelta.between(before, after);
      expect(d.unlocksAvatarStyles, isTrue);
    });

    test('false when null baseline', () {
      final d = ProgressionDelta.between(null, snap(260));
      expect(d.unlocksAvatarStyles, isFalse);
    });

    test('false when level stays the same across a tier boundary value', () {
      // Already at lv3 before and after — no tier newly crossed.
      final d = ProgressionDelta.between(snap(260), snap(300));
      expect(d.leveledUp, isFalse);
      expect(d.unlocksAvatarStyles, isFalse);
    });
  });
}
