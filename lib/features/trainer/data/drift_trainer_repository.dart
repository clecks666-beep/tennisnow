import 'dart:math';

import 'package:drift/drift.dart';

import '../../../shared/data/app_database.dart';
import '../../../shared/domain/match_result.dart';
import '../../../shared/domain/rating.dart';
import '../../../shared/domain/session_type.dart';
import '../../../shared/domain/skill/skill_score.dart';
import '../domain/skill_assessment.dart';
import '../domain/student.dart';
import '../domain/student_goal.dart';
import '../domain/student_session.dart';
import '../domain/student_skill_rating.dart';
import '../domain/student_stats.dart';
import '../domain/training_note.dart';
import '../domain/trainer_repository.dart';

/// Drift-backed [TrainerRepository]. Pure CRUD over the four trainer tables;
/// no cross-feature imports — only shared/data and trainer/domain. Follows the
/// same mapper-per-entity pattern as the rest of the app (CLAUDE.md §2).
class DriftTrainerRepository implements TrainerRepository {
  final AppDatabase _db;

  DriftTrainerRepository(this._db);

  // ── Students ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Student>> watchActiveStudents() {
    return (_db.select(_db.trainerStudents)
          ..where((t) => t.deletedAt.isNull() & t.archivedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_rowToStudent).toList());
  }

  @override
  Future<Student?> studentById(String id) async {
    final row = await (_db.select(_db.trainerStudents)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _rowToStudent(row);
  }

  @override
  Future<void> saveStudent(Student student) {
    return _db.into(_db.trainerStudents).insertOnConflictUpdate(
          TrainerStudentsCompanion(
            id: Value(student.id),
            name: Value(student.name),
            birthYear: Value(student.birthYear),
            category: Value(student.category.name),
            notes: Value(student.notes),
            archivedAt: Value(student.archivedAt),
            createdAt: Value(student.createdAt),
            updatedAt: Value(student.updatedAt),
            deletedAt: Value(student.deletedAt),
          ),
        );
  }

  @override
  Future<void> archiveStudent(String id, DateTime now) {
    return (_db.update(_db.trainerStudents)..where((t) => t.id.equals(id)))
        .write(TrainerStudentsCompanion(
          archivedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  @override
  Future<void> deleteStudent(String id, DateTime now) {
    return (_db.update(_db.trainerStudents)..where((t) => t.id.equals(id)))
        .write(TrainerStudentsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // ── Training notes ────────────────────────────────────────────────────────

  @override
  Stream<List<TrainingNote>> watchNotesForStudent(String studentId) {
    return (_db.select(_db.trainerNotes)
          ..where((t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.sessionDate)]))
        .watch()
        .map((rows) => rows.map(_rowToNote).toList());
  }

  @override
  Future<void> saveNote(TrainingNote note) {
    return _db.into(_db.trainerNotes).insertOnConflictUpdate(
          TrainerNotesCompanion(
            id: Value(note.id),
            studentId: Value(note.studentId),
            type: Value(note.type.name),
            content: Value(note.content),
            sessionDate: Value(note.sessionDate),
            createdAt: Value(note.createdAt),
            updatedAt: Value(note.updatedAt),
            deletedAt: Value(note.deletedAt),
          ),
        );
  }

  @override
  Future<void> deleteNote(String id, DateTime now) {
    return (_db.update(_db.trainerNotes)..where((t) => t.id.equals(id)))
        .write(TrainerNotesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // ── Goals ─────────────────────────────────────────────────────────────────

  @override
  Stream<List<StudentGoal>> watchGoalsForStudent(String studentId) {
    return (_db.select(_db.trainerGoals)
          ..where((t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_rowToGoal).toList());
  }

  @override
  Future<void> saveGoal(StudentGoal goal) {
    return _db.into(_db.trainerGoals).insertOnConflictUpdate(
          TrainerGoalsCompanion(
            id: Value(goal.id),
            studentId: Value(goal.studentId),
            horizon: Value(goal.horizon.name),
            status: Value(goal.status.name),
            title: Value(goal.title),
            description: Value(goal.description),
            dueDate: Value(goal.dueDate),
            completedAt: Value(goal.completedAt),
            createdAt: Value(goal.createdAt),
            updatedAt: Value(goal.updatedAt),
            deletedAt: Value(goal.deletedAt),
          ),
        );
  }

  @override
  Future<void> updateGoalStatus(String id, GoalStatus status, DateTime now) {
    return (_db.update(_db.trainerGoals)..where((t) => t.id.equals(id)))
        .write(TrainerGoalsCompanion(
          status: Value(status.name),
          completedAt:
              Value(status == GoalStatus.done ? now : null),
          updatedAt: Value(now),
        ));
  }

  @override
  Future<void> deleteGoal(String id, DateTime now) {
    return (_db.update(_db.trainerGoals)..where((t) => t.id.equals(id)))
        .write(TrainerGoalsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // ── Skill assessments ─────────────────────────────────────────────────────

  @override
  Stream<List<SkillAssessment>> watchAssessmentsForStudent(String studentId) {
    return (_db.select(_db.trainerAssessments)
          ..where((t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.assessedAt)]))
        .watch()
        .map((rows) => rows.map(_rowToAssessment).toList());
  }

  @override
  Future<void> saveAssessment(SkillAssessment a) {
    return _db.into(_db.trainerAssessments).insertOnConflictUpdate(
          TrainerAssessmentsCompanion(
            id: Value(a.id),
            studentId: Value(a.studentId),
            skillId: Value(a.skillId),
            rating: Value(a.rating),
            notes: Value(a.notes),
            assessedAt: Value(a.assessedAt),
            createdAt: Value(a.createdAt),
            updatedAt: Value(a.updatedAt),
            deletedAt: Value(a.deletedAt),
          ),
        );
  }

  @override
  Future<void> deleteAssessment(String id, DateTime now) {
    return (_db.update(_db.trainerAssessments)..where((t) => t.id.equals(id)))
        .write(TrainerAssessmentsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // ── Student sessions ──────────────────────────────────────────────────────

  @override
  Stream<List<StudentSession>> watchSessionsForStudent(String studentId) {
    return (_db.select(_db.trainerStudentSessions)
          ..where((t) =>
              t.studentId.equals(studentId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]))
        .watch()
        .map((rows) => rows.map(_rowToStudentSession).toList());
  }

  @override
  Future<void> saveStudentSession(StudentSession session) {
    return _db
        .into(_db.trainerStudentSessions)
        .insertOnConflictUpdate(TrainerStudentSessionsCompanion(
          id: Value(session.id),
          studentId: Value(session.studentId),
          type: Value(session.type.storageValue),
          playedAt: Value(session.playedAt),
          result: Value(session.result?.storageValue),
          durationMinutes: Value(session.durationMinutes),
          performance: Value(session.performance?.value),
          mood: Value(session.mood?.value),
          energy: Value(session.energy?.value),
          equipment: Value(session.equipment),
          note: Value(session.note),
          createdAt: Value(session.createdAt),
          updatedAt: Value(session.updatedAt),
          deletedAt: Value(session.deletedAt),
        ));
  }

  @override
  Future<void> deleteStudentSession(String id, DateTime now) {
    return (_db.update(_db.trainerStudentSessions)
          ..where((t) => t.id.equals(id)))
        .write(TrainerStudentSessionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  @override
  Stream<StudentStats> watchStudentStats(String studentId) {
    final s = _db.trainerStudentSessions;
    final total = s.id.count();
    final matchCount = s.id.count(
        filter: s.type.equals(SessionType.match.storageValue));
    final ratedMatchCount = s.id.count(
        filter: s.result.isNotNull() &
            s.type.equals(SessionType.match.storageValue));
    final winCount =
        s.id.count(filter: s.result.equals(MatchResult.win.storageValue));
    final avgPerformance = s.performance.avg();
    final avgMood = s.mood.avg();
    final avgEnergy = s.energy.avg();

    final query = _db.selectOnly(s)
      ..addColumns([
        total,
        matchCount,
        ratedMatchCount,
        winCount,
        avgPerformance,
        avgMood,
        avgEnergy,
      ])
      ..where(s.studentId.equals(studentId) & s.deletedAt.isNull());

    return query.watchSingle().map(
          (row) => StudentStats(
            totalSessions: row.read(total) ?? 0,
            matchCount: row.read(matchCount) ?? 0,
            ratedMatchCount: row.read(ratedMatchCount) ?? 0,
            winCount: row.read(winCount) ?? 0,
            avgPerformance: row.read(avgPerformance),
            avgMood: row.read(avgMood),
            avgEnergy: row.read(avgEnergy),
          ),
        );
  }

  @override
  Stream<List<StudentSession>> watchRecentRatedStudentSessions(
    String studentId, {
    int limit = 20,
  }) {
    return (_db.select(_db.trainerStudentSessions)
          ..where((t) =>
              t.studentId.equals(studentId) &
              t.deletedAt.isNull() &
              t.performance.isNotNull())
          ..orderBy([(t) => OrderingTerm.asc(t.playedAt)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_rowToStudentSession).toList());
  }

  // ── Student skill ratings ─────────────────────────────────────────────────

  @override
  Stream<List<StudentSkillRating>> watchStudentSkillRatings(String studentId) {
    final sr = _db.trainerStudentSkillRatings;
    final ss = _db.trainerStudentSessions;
    final query = _db.select(sr).join([
      innerJoin(ss, ss.id.equalsExp(sr.studentSessionId)),
    ])
      ..where(ss.studentId.equals(studentId) &
          sr.deletedAt.isNull() &
          ss.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(sr.recordedAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => _rowToSkillRating(r.readTable(sr))).toList());
  }

  @override
  Stream<List<SkillScore>> watchStudentSkillScores(String studentId) {
    return watchStudentSkillRatings(studentId).map((ratings) {
      if (ratings.isEmpty) return const [];
      const halfLifeDays = 60.0;
      final now = DateTime.now();
      final bySkill = <String, List<StudentSkillRating>>{};
      for (final r in ratings) {
        bySkill.putIfAbsent(r.skillId, () => []).add(r);
      }
      final result = <SkillScore>[];
      bySkill.forEach((skillId, list) {
        var weightSum = 0.0;
        var valueSum = 0.0;
        for (final r in list) {
          final ageDays = now.difference(r.recordedAt).inDays.toDouble();
          final weight =
              pow(0.5, (ageDays < 0 ? 0.0 : ageDays) / halfLifeDays).toDouble();
          weightSum += weight;
          valueSum += r.value * weight;
        }
        result.add(SkillScore(
          skillId: skillId,
          value: weightSum == 0 ? 0 : valueSum / weightSum,
          sampleCount: list.length,
        ));
      });
      result.sort((a, b) => b.value.compareTo(a.value));
      return result;
    });
  }

  @override
  Future<Map<String, int>> studentSkillRatingsForSession(
      String studentSessionId) async {
    final rows = await (_db.select(_db.trainerStudentSkillRatings)
          ..where((t) =>
              t.studentSessionId.equals(studentSessionId) &
              t.deletedAt.isNull()))
        .get();
    return {for (final r in rows) r.skillId: r.value};
  }

  @override
  Future<void> replaceStudentSkillRatingsForSession(
    String studentSessionId,
    DateTime recordedAt,
    Map<String, int> skillValues,
    DateTime now,
  ) async {
    await _db.transaction(() async {
      // Soft-delete existing.
      await (_db.update(_db.trainerStudentSkillRatings)
            ..where((t) => t.studentSessionId.equals(studentSessionId)))
          .write(TrainerStudentSkillRatingsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ));
      // Insert new rows.
      for (final entry in skillValues.entries) {
        await _db
            .into(_db.trainerStudentSkillRatings)
            .insertOnConflictUpdate(TrainerStudentSkillRatingsCompanion(
              id: Value('${studentSessionId}_${entry.key}'),
              studentSessionId: Value(studentSessionId),
              skillId: Value(entry.key),
              value: Value(entry.value),
              recordedAt: Value(recordedAt),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }
    });
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  Student _rowToStudent(TrainerStudent row) => Student(
        id: row.id,
        name: row.name,
        birthYear: row.birthYear,
        category: StudentCategory.values.firstWhere((e) => e.name == row.category,
            orElse: () => StudentCategory.adult),
        notes: row.notes,
        archivedAt: row.archivedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  TrainingNote _rowToNote(TrainerNote row) => TrainingNote(
        id: row.id,
        studentId: row.studentId,
        type: NoteType.values.firstWhere((e) => e.name == row.type,
            orElse: () => NoteType.general),
        content: row.content,
        sessionDate: row.sessionDate,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  StudentGoal _rowToGoal(TrainerGoal row) => StudentGoal(
        id: row.id,
        studentId: row.studentId,
        horizon: GoalHorizon.values.firstWhere((e) => e.name == row.horizon,
            orElse: () => GoalHorizon.short),
        status: GoalStatus.values.firstWhere((e) => e.name == row.status,
            orElse: () => GoalStatus.open),
        title: row.title,
        description: row.description,
        dueDate: row.dueDate,
        completedAt: row.completedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  SkillAssessment _rowToAssessment(TrainerAssessment row) => SkillAssessment(
        id: row.id,
        studentId: row.studentId,
        skillId: row.skillId,
        rating: row.rating,
        notes: row.notes,
        assessedAt: row.assessedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  StudentSession _rowToStudentSession(TrainerStudentSession row) =>
      StudentSession(
        id: row.id,
        studentId: row.studentId,
        type: SessionType.fromStorage(row.type),
        playedAt: row.playedAt,
        result: MatchResult.fromStorage(row.result),
        durationMinutes: row.durationMinutes,
        performance: Rating.tryFrom(row.performance),
        mood: Rating.tryFrom(row.mood),
        energy: Rating.tryFrom(row.energy),
        equipment: row.equipment,
        note: row.note,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  StudentSkillRating _rowToSkillRating(TrainerStudentSkillRating row) =>
      StudentSkillRating(
        id: row.id,
        studentSessionId: row.studentSessionId,
        skillId: row.skillId,
        value: row.value,
        recordedAt: row.recordedAt,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );
}
