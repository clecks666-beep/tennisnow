import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/features/quests/domain/quest.dart';
import 'package:tennisnow/features/quests/domain/weekly_quests.dart';

void main() {
  // A Wednesday → its week runs Mon 2024-06-03 .. Sun 2024-06-09 (end exclusive
  // Mon 2024-06-10).
  final now = DateTime(2024, 6, 5, 14);

  QuestSessionInput session(
    String id,
    DateTime playedAt, {
    bool hasFeeling = false,
  }) =>
      QuestSessionInput(id: id, playedAt: playedAt, hasFeeling: hasFeeling);

  QuestProgress questById(WeeklyQuestBoard board, String id) =>
      board.items.firstWhere((q) => q.quest.id == id);

  group('WeeklyQuests.boardFor — window', () {
    test('counts only sessions inside the current week', () {
      final board = WeeklyQuests.boardFor(
        now,
        [
          session('a', DateTime(2024, 6, 3)), // Mon — in (inclusive start)
          session('b', DateTime(2024, 6, 5)), // Wed — in
          session('c', DateTime(2024, 6, 9, 23)), // Sun — in
          session('d', DateTime(2024, 6, 2)), // prev Sun — out
          session('e', DateTime(2024, 6, 10)), // next Mon — out (exclusive end)
        ],
        const [],
      );

      final rhythm = questById(board, 'weekly_rhythm');
      expect(rhythm.current, 3);
      expect(rhythm.isComplete, isTrue); // target 3
      expect(board.weekStart, DateTime(2024, 6, 3));
      expect(board.weekEnd, DateTime(2024, 6, 10));
    });
  });

  group('WeeklyQuests.boardFor — feeling quest', () {
    test('counts only in-week sessions that recorded a feeling', () {
      final board = WeeklyQuests.boardFor(
        now,
        [
          session('a', DateTime(2024, 6, 4), hasFeeling: true),
          session('b', DateTime(2024, 6, 6), hasFeeling: true),
          session('c', DateTime(2024, 6, 7)), // no feeling
          session('d', DateTime(2024, 6, 1), hasFeeling: true), // out of week
        ],
        const [],
      );

      final tuneIn = questById(board, 'weekly_tune_in');
      expect(tuneIn.current, 2);
      expect(tuneIn.isComplete, isTrue); // target 2
      expect(tuneIn.remaining, 0);
    });
  });

  group('WeeklyQuests.boardFor — skill focus quest', () {
    test('counts distinct in-week sessions tagged with the focus skill', () {
      // Read the rotating focus skill the board chose, then tag against it.
      final probe = WeeklyQuests.boardFor(now, const [], const []);
      final focusSkillId = questById(probe, 'weekly_skill_focus').quest.skillId!;

      final board = WeeklyQuests.boardFor(
        now,
        [
          session('s1', DateTime(2024, 6, 3)),
          session('s2', DateTime(2024, 6, 6)),
          session('s3', DateTime(2024, 6, 1)), // out of week
        ],
        [
          // s1 tagged twice with focus skill -> distinct counts once.
          QuestSkillInput(sessionId: 's1', skillId: focusSkillId),
          QuestSkillInput(sessionId: 's1', skillId: focusSkillId),
          // s2 tagged with focus skill -> counts.
          QuestSkillInput(sessionId: 's2', skillId: focusSkillId),
          // s2 also tagged with a different skill -> ignored.
          QuestSkillInput(sessionId: 's2', skillId: 'power'),
          // out-of-week session tagged -> ignored.
          QuestSkillInput(sessionId: 's3', skillId: focusSkillId),
        ],
      );

      final focus = questById(board, 'weekly_skill_focus');
      expect(focus.current, 2); // s1 + s2, distinct
      expect(focus.isComplete, isTrue); // target 2
    });
  });

  group('WeeklyQuests — rotation determinism', () {
    test('same week -> same focus skill; consecutive weeks differ', () {
      final thisWeek = WeeklyQuests.boardFor(now, const [], const []);
      final sameWeekAgain =
          WeeklyQuests.boardFor(now.add(const Duration(days: 1)), const [], const []);
      final nextWeek =
          WeeklyQuests.boardFor(now.add(const Duration(days: 7)), const [], const []);

      String focus(WeeklyQuestBoard b) =>
          questById(b, 'weekly_skill_focus').quest.skillId!;

      expect(focus(thisWeek), focus(sameWeekAgain));
      expect(focus(thisWeek), isNot(focus(nextWeek)));
      // The focus skill is always a real, catalog skill id.
      expect(WeeklyQuests.focusSkillRotation, contains(focus(thisWeek)));
    });
  });

  group('WeeklyQuests — progress maths', () {
    test('empty history -> all quests at zero, none complete', () {
      final board = WeeklyQuests.boardFor(now, const [], const []);
      expect(board.total, 3);
      expect(board.completedCount, 0);
      expect(board.allComplete, isFalse);
      for (final q in board.items) {
        expect(q.current, 0);
        expect(q.fraction, 0);
        expect(q.isComplete, isFalse);
        expect(q.remaining, q.target);
      }
    });

    test('fraction is clamped to 0..1 even when over target', () {
      final board = WeeklyQuests.boardFor(
        now,
        [
          session('a', DateTime(2024, 6, 3)),
          session('b', DateTime(2024, 6, 4)),
          session('c', DateTime(2024, 6, 5)),
          session('d', DateTime(2024, 6, 6)),
          session('e', DateTime(2024, 6, 7)), // 5 sessions, rhythm target 3
        ],
        const [],
      );
      final rhythm = questById(board, 'weekly_rhythm');
      expect(rhythm.current, 5);
      expect(rhythm.fraction, 1.0);
      expect(rhythm.remaining, 0);
    });
  });
}
