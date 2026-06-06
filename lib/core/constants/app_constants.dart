/// App-wide constants. No magic values scattered in widgets (CLAUDE.md §3).
class AppConstants {
  AppConstants._();

  static const String appName = 'tennisnow';

  /// User-facing version label (keep in sync with pubspec `version`).
  static const String appVersion = '0.1.0';

  /// One-line product description shown in Settings/About.
  static const String tagline =
      'Your personal tennis companion — log fast, see what lifts your game.';

  /// Local Drift database file name.
  static const String databaseName = 'tennisnow_db';

  /// Quick-pick session durations (minutes) offered in the log form.
  static const List<int> quickDurationsMinutes = [30, 45, 60, 90];

  /// Inclusive bounds for self-rated scales (performance, mood, energy).
  static const int minRating = 1;
  static const int maxRating = 5;
}
