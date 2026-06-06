/// Whether a logged session was a competitive match or a training session.
/// Stored by [storageValue] so persistence is stable even if names change.
///
/// Lives in shared/domain because multiple features reason about it
/// (session_logging entities + settings' default-type preference) — see
/// CLAUDE.md §2 cross-feature rule.
enum SessionType {
  training('training', 'Training'),
  match('match', 'Match');

  final String storageValue;
  final String label;

  const SessionType(this.storageValue, this.label);

  static SessionType fromStorage(String value) {
    return SessionType.values.firstWhere(
      (t) => t.storageValue == value,
      orElse: () => SessionType.training,
    );
  }
}
