/// Whether a logged session was a competitive match or a training session.
/// Stored by [storageValue] so persistence is stable even if names change.
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
