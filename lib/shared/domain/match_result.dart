/// Outcome of a match. Only meaningful when the session is a match;
/// null for training sessions.
enum MatchResult {
  win('win', 'Win'),
  loss('loss', 'Loss'),
  draw('draw', 'Draw');

  final String storageValue;
  final String label;

  const MatchResult(this.storageValue, this.label);

  static MatchResult? fromStorage(String? value) {
    if (value == null) return null;
    for (final result in MatchResult.values) {
      if (result.storageValue == value) return result;
    }
    return null;
  }
}
