import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'skill_rating_providers.dart';

/// Persists a session's skill self-ratings. AsyncNotifier exposes
/// loading/error/success (do-not-break rule #5). Composed by the log screen
/// after a session is saved (public surface — CLAUDE.md §2).
class SkillRatingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Loads the skill→value map currently stored for [sessionId] (edit prefill).
  Future<Map<String, int>> loadForSession(String sessionId) {
    return ref.read(skillRatingRepositoryProvider).ratingsForSession(sessionId);
  }

  /// Replaces a session's skill ratings. Returns true on success.
  Future<bool> save(
    String sessionId,
    DateTime recordedAt,
    Map<String, int> skillValues,
  ) async {
    state = const AsyncLoading();
    final repo = ref.read(skillRatingRepositoryProvider);
    state = await AsyncValue.guard(
      () => repo.replaceForSession(sessionId, recordedAt, skillValues),
    );
    return !state.hasError;
  }
}

final skillRatingControllerProvider =
    AsyncNotifierProvider<SkillRatingController, void>(
  SkillRatingController.new,
);
