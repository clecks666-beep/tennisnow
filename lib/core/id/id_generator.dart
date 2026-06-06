import 'package:uuid/uuid.dart';

/// Client-side ID generation for the sync-ready invariant (CLAUDE.md §2).
/// Every persisted entity gets a UUID v4 generated here.
class IdGenerator {
  IdGenerator._();

  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
