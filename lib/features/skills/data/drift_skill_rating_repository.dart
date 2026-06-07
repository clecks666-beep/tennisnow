import 'package:drift/drift.dart';

import '../../../core/id/id_generator.dart';
import '../../../shared/data/app_database.dart';
import '../domain/skill_rating_repository.dart';
import '../domain/skill_self_rating.dart';
import 'skill_rating_mapper.dart';

/// Drift-backed [SkillRatingRepository]. The only place that knows about the
/// database for skill ratings; the rest of the app uses the interface.
class DriftSkillRatingRepository implements SkillRatingRepository {
  final AppDatabase _db;

  DriftSkillRatingRepository(this._db);

  @override
  Stream<List<SkillSelfRating>> watchActive() {
    return _db.watchActiveSkillRatings().map(
          (rows) => rows.map(SkillRatingMapper.toDomain).toList(),
        );
  }

  @override
  Future<Map<String, int>> ratingsForSession(String sessionId) async {
    final rows = await _db.skillRatingsForSession(sessionId);
    return {for (final r in rows) r.skillId: r.value};
  }

  @override
  Future<void> replaceForSession(
    String sessionId,
    DateTime recordedAt,
    Map<String, int> skillValues,
  ) {
    final now = DateTime.now();
    final rows = skillValues.entries
        .map(
          (e) => SkillRatingsCompanion.insert(
            id: IdGenerator.newId(),
            sessionId: sessionId,
            skillId: e.key,
            value: e.value,
            recordedAt: recordedAt,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList();
    return _db.replaceSkillRatingsForSession(sessionId, rows, now);
  }
}
