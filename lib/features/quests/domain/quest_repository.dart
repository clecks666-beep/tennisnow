import 'quest.dart';

/// Reactive source of the player's weekly quest board. Implemented in data/ over
/// the shared database; the UI depends only on this interface (CLAUDE.md §2).
abstract interface class QuestRepository {
  /// Emits a fresh [WeeklyQuestBoard] whenever the underlying sessions or skill
  /// tags change, so completing a quest shows up the moment it's earned.
  Stream<WeeklyQuestBoard> watch();
}
