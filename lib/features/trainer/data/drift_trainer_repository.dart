import 'package:drift/drift.dart';

import '../../../shared/data/app_database.dart';
import '../domain/skill_assessment.dart';
import '../domain/student.dart';
import '../domain/student_goal.dart';
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
}
