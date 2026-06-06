/// The player's logging streak. Pure domain value.
///
/// [current] is the run of consecutive days ending today (or yesterday, as a
/// one-day grace so a streak isn't "lost" until a full day is missed).
/// [longest] is the best run ever. [activeToday] is true once today is logged.
class Streak {
  final int current;
  final int longest;
  final bool activeToday;

  const Streak({
    required this.current,
    required this.longest,
    required this.activeToday,
  });

  static const none = Streak(current: 0, longest: 0, activeToday: false);
}
