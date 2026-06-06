import '../../core/constants/app_constants.dart';

/// A 1–5 self-rating value object (performance, mood, energy).
///
/// Enforces its invariant at the domain boundary (CLAUDE.md §7): a Rating can
/// only exist with a value in [minRating, maxRating]. Pure Dart — no Flutter,
/// no I/O — so it lives in the domain layer.
class Rating {
  final int value;

  const Rating._(this.value);

  /// Returns a Rating, or throws [ArgumentError] if out of range.
  factory Rating(int value) {
    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      throw ArgumentError.value(
        value,
        'value',
        'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}',
      );
    }
    return Rating._(value);
  }

  /// Safe parse from persistence/UI: returns null instead of throwing.
  static Rating? tryFrom(int? value) {
    if (value == null) return null;
    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      return null;
    }
    return Rating._(value);
  }

  @override
  bool operator ==(Object other) => other is Rating && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Rating($value)';
}
