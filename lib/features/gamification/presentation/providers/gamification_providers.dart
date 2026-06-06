import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_gamification_repository.dart';
import '../../domain/gamification_repository.dart';
import '../../domain/gamification_snapshot.dart';

/// Exposes the gamification repository via its domain interface (CLAUDE.md §2).
final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return DriftGamificationRepository(ref.watch(appDatabaseProvider));
});

/// Live streak + achievements. Recomputes automatically as sessions change.
final gamificationProvider = StreamProvider<GamificationSnapshot>((ref) {
  return ref.watch(gamificationRepositoryProvider).watch();
});
