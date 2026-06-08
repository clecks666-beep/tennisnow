import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/settings/presentation/providers/settings_controller.dart';
import '../../../../shared/data/database_provider.dart';
import '../../data/drift_trainer_repository.dart';
import '../../domain/student.dart';
import '../../domain/training_note.dart';
import '../../domain/trainer_repository.dart';

final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftTrainerRepository(db);
});

final trainerModeProvider = Provider<bool>((ref) {
  return ref.watch(
      settingsControllerProvider.select((s) => s.trainerModeEnabled));
});

final activeStudentsProvider = StreamProvider<List<Student>>((ref) {
  return ref.watch(trainerRepositoryProvider).watchActiveStudents();
});

final notesForStudentProvider =
    StreamProvider.family<List<TrainingNote>, String>((ref, studentId) {
  return ref.watch(trainerRepositoryProvider).watchNotesForStudent(studentId);
});
