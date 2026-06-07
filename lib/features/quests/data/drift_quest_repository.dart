import '../../../core/utils/combine_latest.dart';
import '../../../shared/data/app_database.dart';
import '../domain/quest.dart';
import '../domain/quest_repository.dart';
import '../domain/weekly_quests.dart';

/// Composes the weekly quest board from the shared database. The same seam shape
/// as DriftGamificationRepository: reactive DB reads are mapped into pure-domain
/// carriers, then handed to the deterministic [WeeklyQuests.boardFor] evaluator —
/// no scoring logic lives here or in SQL (CLAUDE.md §2/§3).
///
/// The clock is injectable so the "which week is it" decision is testable and
/// the whole board stays deterministic.
class DriftQuestRepository implements QuestRepository {
  final AppDatabase _db;
  final DateTime Function() _now;

  DriftQuestRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  @override
  Stream<WeeklyQuestBoard> watch() {
    return combineLatest2(
      _db.watchActiveSessions(),
      _db.watchActiveSkillRatings(),
      (List<Session> sessions, List<SkillRating> ratings) {
        final sessionInputs = sessions
            .map((s) => QuestSessionInput(
                  id: s.id,
                  playedAt: s.playedAt,
                  hasFeeling: s.mood != null || s.energy != null,
                ))
            .toList();
        final skillInputs = ratings
            .map((r) => QuestSkillInput(sessionId: r.sessionId, skillId: r.skillId))
            .toList();
        return WeeklyQuests.boardFor(_now(), sessionInputs, skillInputs);
      },
    );
  }
}
