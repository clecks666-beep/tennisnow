import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_progress_repository.dart';
import '../../domain/progress_repository.dart';
import '../../domain/session_stats.dart';
import '../../domain/trend_point.dart';

/// How many recent rated sessions feed the trend sparkline.
const int kTrendLength = 12;

/// Exposes the progress repository via its domain interface (CLAUDE.md §2).
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.watch(appDatabaseProvider));
});

/// Live aggregate stats. StreamProvider so the screen updates automatically as
/// sessions are logged or deleted (CLAUDE.md §6 reactive over poll).
final sessionStatsProvider = StreamProvider<SessionStats>((ref) {
  return ref.watch(progressRepositoryProvider).watchStats();
});

/// Live performance trend for the sparkline.
final performanceTrendProvider = StreamProvider<List<TrendPoint>>((ref) {
  return ref
      .watch(progressRepositoryProvider)
      .watchPerformanceTrend(limit: kTrendLength);
});
