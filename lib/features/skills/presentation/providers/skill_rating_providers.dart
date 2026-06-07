import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/database_provider.dart';
import '../../data/drift_skill_rating_repository.dart';
import '../../../../shared/domain/skill/skill_score.dart';
import '../../domain/skill_rating_calculator.dart';
import '../../domain/skill_rating_repository.dart';

/// Exposes the skill-rating repository via its domain interface (CLAUDE.md §2).
final skillRatingRepositoryProvider = Provider<SkillRatingRepository>((ref) {
  return DriftSkillRatingRepository(ref.watch(appDatabaseProvider));
});

/// Live, recency-weighted skill scores (best current form first). Public
/// surface other features may compose (e.g. the Progress "Your skills" section).
final skillScoresProvider = StreamProvider<List<SkillScore>>((ref) {
  final repo = ref.watch(skillRatingRepositoryProvider);
  return repo.watchActive().map(
        (ratings) => SkillRatingCalculator.scores(ratings, DateTime.now()),
      );
});
