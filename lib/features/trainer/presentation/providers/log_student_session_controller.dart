import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/id/id_generator.dart';
import '../../../../shared/domain/match_result.dart';
import '../../../../shared/domain/rating.dart';
import '../../../../shared/domain/session_type.dart';
import '../../domain/student_session.dart';
import 'trainer_providers.dart';

/// Ephemeral form state for a student session — mirrors [SessionDraft] but
/// owned by the trainer feature and linked to a student.
class StudentSessionDraft {
  final SessionType type;
  final MatchResult? result;
  final int? durationMinutes;
  final int? performance;
  final int? mood;
  final int? energy;
  final String? equipment;
  final String? note;

  const StudentSessionDraft({
    this.type = SessionType.training,
    this.result,
    this.durationMinutes,
    this.performance,
    this.mood,
    this.energy,
    this.equipment,
    this.note,
  });
}

/// Saves a [StudentSession] for a specific student. Mirrors [LogSessionController]
/// but uses the trainer repository (no XP/gamification — coaching data stays
/// separate from the player's own progression).
class LogStudentSessionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<StudentSession?> save(
    String studentId,
    StudentSessionDraft draft, {
    StudentSession? existing,
  }) async {
    final now = DateTime.now();
    final String? trimmedNote =
        draft.note?.trim().isEmpty == true ? null : draft.note?.trim();
    final String? trimmedEquipment =
        draft.equipment?.trim().isEmpty == true ? null : draft.equipment?.trim();

    final session = StudentSession(
      id: existing?.id ?? IdGenerator.newId(),
      studentId: studentId,
      type: draft.type,
      playedAt: existing?.playedAt ?? now,
      result: draft.type == SessionType.match ? draft.result : null,
      durationMinutes: draft.durationMinutes,
      performance: Rating.tryFrom(draft.performance),
      mood: Rating.tryFrom(draft.mood),
      energy: Rating.tryFrom(draft.energy),
      equipment: trimmedEquipment,
      note: trimmedNote,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(trainerRepositoryProvider).saveStudentSession(session),
    );

    return state.hasError ? null : session;
  }
}

final logStudentSessionControllerProvider =
    AsyncNotifierProvider<LogStudentSessionController, void>(
  LogStudentSessionController.new,
);
