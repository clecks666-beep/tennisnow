import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/gamification/domain/badge.dart';
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

    test('skill_rated badge earns on first skill-tagged session', () {
      final withSkill = BadgeCatalog.evaluate(
        const GamificationInputs(
          totalSessions: 1,
          streakDays: 0,
          matches: 0,
          wins: 0,
          skillTaggedSessions: 1,
        ),
      );
      final withoutSkill = BadgeCatalog.evaluate(
        const GamificationInputs(
          totalSessions: 5,
          streakDays: 0,
          matches: 0,
          wins: 0,
        ),
      );
      expect(
        withSkill.firstWhere((a) => a.badge.id == 'skill_rated').earned,
        isTrue,
      );
      expect(
        withoutSkill.firstWhere((a) => a.badge.id == 'skill_rated').earned,
        isFalse,
      );
    });

    test('higher volume badges earn at correct thresholds', () {
      final at100 = BadgeCatalog.evaluate(
        const GamificationInputs(
            totalSessions: 100, streakDays: 0, matches: 0, wins: 0),
      );
      final at199 = BadgeCatalog.evaluate(
        const GamificationInputs(
            totalSessions: 199, streakDays: 0, matches: 0, wins: 0),
      );
      final at200 = BadgeCatalog.evaluate(
        const GamificationInputs(
            totalSessions: 200, streakDays: 0, matches: 0, wins: 0),
      );
      expect(
          at100.firstWhere((a) => a.badge.id == 'hundred_sessions').earned,
          isTrue);
      expect(
          at199.firstWhere((a) => a.badge.id == 'two_hundred_sessions').earned,
          isFalse);
      expect(
          at200.firstWhere((a) => a.badge.id == 'two_hundred_sessions').earned,
          isTrue);
    });
  });

  group('BadgeRarity', () {
    test('standard badges have standard rarity', () {
      for (final def in [
        'first_session', 'ten_sessions', 'streak_3', 'first_win',
        'ten_matches', 'skill_rated'
      ]) {
        final badge = BadgeCatalog.all.firstWhere((b) => b.id == def);
        expect(badge.rarity, BadgeRarity.standard,
            reason: '$def should be standard');
      }
    });

    test('rare badges are marked rare', () {
      for (final id in ['fifty_sessions', 'streak_7', 'ten_wins']) {
        expect(BadgeCatalog.all.firstWhere((b) => b.id == id).rarity,
            BadgeRarity.rare,
            reason: '$id should be rare');
      }
    });

    test('epic badges are marked epic', () {
      for (final id in ['hundred_sessions', 'streak_14', 'fifty_matches']) {
        expect(BadgeCatalog.all.firstWhere((b) => b.id == id).rarity,
            BadgeRarity.epic,
            reason: '$id should be epic');
      }
    });

    test('legendary badges are marked legendary', () {
      for (final id in ['two_hundred_sessions', 'streak_30', 'hundred_wins']) {
        expect(BadgeCatalog.all.firstWhere((b) => b.id == id).rarity,
            BadgeRarity.legendary,
            reason: '$id should be legendary');
      }
    });

    test('all badge ids in the catalog are unique', () {
      final ids = BadgeCatalog.all.map((b) => b.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
