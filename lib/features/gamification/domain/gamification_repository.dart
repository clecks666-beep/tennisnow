import 'gamification_snapshot.dart';

/// Domain contract for the read-only motivation views (streak + badges).
/// The UI depends on this interface only — never on Drift (CLAUDE.md §2).
abstract interface class GamificationRepository {
  /// Live streak + evaluated achievements, recomputed whenever sessions change.
  Stream<GamificationSnapshot> watch();
}
