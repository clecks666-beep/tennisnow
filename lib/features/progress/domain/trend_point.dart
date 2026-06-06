/// A single point on the performance trend: when a session happened and its
/// self-rated performance (1–5). Pure domain object.
class TrendPoint {
  final DateTime playedAt;
  final int performance;

  const TrendPoint({required this.playedAt, required this.performance});
}
