import '../../../shared/domain/skill/skill_score.dart';
import 'skill_assessment.dart';
import 'student.dart';
import 'student_goal.dart';
import 'student_session.dart';
import 'student_skill_rating.dart';
import 'student_stats.dart';
import 'training_note.dart';

/// Interface for all trainer data operations. Feature-owned (not shared/) because
/// only the trainer feature reads this data. The Drift implementation and a future
/// Supabase-sync implementation both satisfy this contract.
abstract class TrainerRepository {
  // ── Students ──────────────────────────────────────────────────────────────
  Stream<List<Student>> watchActiveStudents();
  Future<Student?> studentById(String id);
  Future<void> saveStudent(Student student);
  Future<void> archiveStudent(String id, DateTime now);
  Future<void> deleteStudent(String id, DateTime now);

  // ── Training notes ────────────────────────────────────────────────────────
  Stream<List<TrainingNote>> watchNotesForStudent(String studentId);
  Future<void> saveNote(TrainingNote note);
  Future<void> deleteNote(String id, DateTime now);

  // ── Goals ─────────────────────────────────────────────────────────────────
  Stream<List<StudentGoal>> watchGoalsForStudent(String studentId);
  Future<void> saveGoal(StudentGoal goal);
  Future<void> updateGoalStatus(String id, GoalStatus status, DateTime now);
  Future<void> deleteGoal(String id, DateTime now);

  // ── Skill assessments ─────────────────────────────────────────────────────
  Stream<List<SkillAssessment>> watchAssessmentsForStudent(String studentId);
  Future<void> saveAssessment(SkillAssessment assessment);
  Future<void> deleteAssessment(String id, DateTime now);

  // ── Student sessions ──────────────────────────────────────────────────────
  Stream<List<StudentSession>> watchSessionsForStudent(String studentId);
  Future<void> saveStudentSession(StudentSession session);
  Future<void> deleteStudentSession(String id, DateTime now);

  /// Aggregate stats (totals, averages) for one student's sessions.
  Stream<StudentStats> watchStudentStats(String studentId);

  /// Up to [limit] recent sessions that have a performance rating — used for
  /// the trend line chart.
  Stream<List<StudentSession>> watchRecentRatedStudentSessions(
    String studentId, {
    int limit = 20,
  });

  // ── Student skill ratings ─────────────────────────────────────────────────

  /// All active skill ratings for a student across all their sessions.
  Stream<List<StudentSkillRating>> watchStudentSkillRatings(String studentId);

  /// Recency-weighted skill scores for a student (computed from raw ratings).
  Stream<List<SkillScore>> watchStudentSkillScores(String studentId);

  /// Returns the skillId → value map stored for [studentSessionId] (edit prefill).
  Future<Map<String, int>> studentSkillRatingsForSession(
      String studentSessionId);

  /// Replaces all skill ratings for [studentSessionId] atomically.
  Future<void> replaceStudentSkillRatingsForSession(
    String studentSessionId,
    DateTime recordedAt,
    Map<String, int> skillValues,
    DateTime now,
  );
}
