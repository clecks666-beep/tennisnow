import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/gamification_repository.dart';
import '../../domain/gamification_snapshot.dart';
import '../../domain/progression_delta.dart';
import '../widgets/progression_feedback.dart';
import 'gamification_providers.dart';

/// Public gamification surface that lets other features deliver "felt" rewards
/// (★/§4: progression must be felt) WITHOUT touching gamification internals.
///
/// Usage: capture a baseline when an action begins, then [showEarned] once it's
/// persisted — it diffs the snapshot and shows exactly what was earned. The
/// snapshot types and delta logic stay inside gamification; callers only hold
/// this object (obtained from [progressionRewardProvider]).
class ProgressionReward {
  final GamificationRepository _repo;
  GamificationSnapshot? _baseline;

  ProgressionReward(this._repo);

  /// Records the current progression as the baseline to diff against. Best
  /// called when a logging screen opens, so it adds no latency to Save.
  Future<void> captureBaseline() async {
    try {
      _baseline = await _repo.watch().first;
    } catch (_) {
      _baseline = null; // honest fallback: no baseline → no celebration
    }
  }

  /// Reads the post-action snapshot and shows the earned feedback on [messenger]
  /// (safe to call after the originating screen has popped — it depends only on
  /// the captured repository and messenger, not on a widget).
  Future<void> showEarned(
    ScaffoldMessengerState messenger, {
    required bool isEdit,
  }) async {
    GamificationSnapshot after;
    try {
      after = await _repo.watch().first;
    } catch (_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Session updated' : 'Session logged 🎾'),
          ),
        );
      return;
    }
    final delta = ProgressionDelta.between(_baseline, after);
    showProgressionFeedback(messenger, isEdit: isEdit, delta: delta);
  }
}

/// A fresh [ProgressionReward] bound to the gamification repository.
final progressionRewardProvider = Provider<ProgressionReward>((ref) {
  return ProgressionReward(ref.watch(gamificationRepositoryProvider));
});
