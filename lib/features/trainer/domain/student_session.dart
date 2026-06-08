import '../../../shared/domain/match_result.dart';
import '../../../shared/domain/rating.dart';
import '../../../shared/domain/session_type.dart';

/// A session logged BY THE TRAINER for a student — same fields as [TennisSession]
/// (performance, mood, energy, equipment, skills) but owned by the trainer
/// feature and linked to a student. Keeps trainer data cleanly separate from
/// the player's own gamification and XP.
class StudentSession {
  final String id;
  final String studentId;
  final SessionType type;
  final DateTime playedAt;
  final MatchResult? result;
  final int? durationMinutes;
  final Rating? performance;
  final Rating? mood;
  final Rating? energy;
  final String? equipment;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const StudentSession({
    required this.id,
    required this.studentId,
    required this.type,
    required this.playedAt,
    this.result,
    this.durationMinutes,
    this.performance,
    this.mood,
    this.energy,
    this.equipment,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isMatch => type == SessionType.match;
  bool get isDeleted => deletedAt != null;

  StudentSession copyWith({
    String? id,
    String? studentId,
    SessionType? type,
    DateTime? playedAt,
    MatchResult? result,
    int? durationMinutes,
    Rating? performance,
    Rating? mood,
    Rating? energy,
    String? equipment,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return StudentSession(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      playedAt: playedAt ?? this.playedAt,
      result: result ?? this.result,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      performance: performance ?? this.performance,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      equipment: equipment ?? this.equipment,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
