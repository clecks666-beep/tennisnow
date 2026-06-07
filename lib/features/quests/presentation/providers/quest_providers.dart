import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_quest_repository.dart';
import '../../domain/quest.dart';
import '../../domain/quest_repository.dart';

/// Exposes the quest repository via its domain interface (CLAUDE.md §2).
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return DriftQuestRepository(ref.watch(appDatabaseProvider));
});

/// Live weekly quest board. Recomputes as sessions / skill tags change, so a
/// completed quest appears the instant it's earned.
final questBoardProvider = StreamProvider<WeeklyQuestBoard>((ref) {
  return ref.watch(questRepositoryProvider).watch();
});
