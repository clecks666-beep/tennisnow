import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local UI preferences (see ADR-005). This store is intentionally
/// SEPARATE from the Drift database: these flags describe how the app behaves on
/// THIS device (e.g. onboarding seen) and must never sync across devices, so
/// they stay out of the sync-ready domain schema.
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static const String _kOnboardingComplete = 'onboarding_complete';

  /// Whether the user has finished (or skipped) first-launch onboarding.
  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);
}

/// Holds the SharedPreferences instance. Overridden in main() with the loaded
/// instance so the rest of the app can read preferences synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

final appPreferencesProvider = Provider<AppPreferences>(
  (ref) => AppPreferences(ref.watch(sharedPreferencesProvider)),
);
