import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Owns the single AppDatabase instance for the app lifetime, shared by every
/// feature that needs persistence. Created once here — never opened ad-hoc.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
