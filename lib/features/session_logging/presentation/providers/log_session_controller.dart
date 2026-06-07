import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/id/id_generator.dart';
import '../../../../shared/domain/rating.dart';
import '../../../../shared/domain/session_type.dart';
import '../../domain/match_result.dart';
import '../../domain/tennis_session.dart';
import 'session_providers.dart';

/// Immutable draft built up by the log form before saving. Lives outside the
/// widget so the save logic stays out of the UI (CLAUDE.md §3).
class SessionDraft {
  final SessionType type;
  final MatchResult? result;
  final int? durationMinutes;
  final int? performance;
  final int? mood;
  final int? energy;
  final String? equipment;
  final String? note;

  const SessionDraft({
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

/// Handles persisting a session (new or edited). AsyncNotifier exposes
/// loading/error/success so the screen can render a real state for each
/// (do-not-break rule #5).
class LogSessionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Builds a [TennisSession] from the draft and saves it (upsert by id).
  /// When [existing] is given this is an edit: id, createdAt and playedAt are
  /// preserved and only updatedAt is bumped. Returns the saved session on
  /// success (so the caller can attach skill ratings), or null on error.
  Future<TennisSession?> save(SessionDraft draft, {TennisSession? existing}) async {
    state = const AsyncLoading();
    final repository = ref.read(sessionRepositoryProvider);
    final now = DateTime.now();

    final session = TennisSession(
      id: existing?.id ?? IdGenerator.newId(),
      type: draft.type,
      playedAt: existing?.playedAt ?? now,
      result: draft.type == SessionType.match ? draft.result : null,
      durationMinutes: draft.durationMinutes,
      performance: Rating.tryFrom(draft.performance),
      mood: Rating.tryFrom(draft.mood),
      energy: Rating.tryFrom(draft.energy),
      equipment: _trimToNull(draft.equipment),
      note: _trimToNull(draft.note),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    state = await AsyncValue.guard(() => repository.add(session));
    return state.hasError ? null : session;
  }

  static String? _trimToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

final logSessionControllerProvider =
    AsyncNotifierProvider<LogSessionController, void>(LogSessionController.new);
