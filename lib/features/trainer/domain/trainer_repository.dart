import 'skill_assessment.dart';
import 'student.dart';
import 'student_goal.dart';
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
}
