import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/avatar/avatar_config.dart';
import '../domain/session_type.dart';

/// Device-local UI preferences (see ADR-005). This store is intentionally
/// SEPARATE from the Drift database: these flags describe how the app behaves on
/// THIS device (e.g. onboarding seen) and must never sync across devices, so
/// they stay out of the sync-ready domain schema.
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static const String _kOnboardingComplete = 'onboarding_complete';
  static const String _kDisplayName = 'display_name';
  static const String _kDefaultSessionType = 'default_session_type';
  static const String _kAvatarConfig = 'avatar_config';

  /// Whether the user has finished (or skipped) first-launch onboarding.
  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);

  /// Optional display name used to personalize the app. Empty is treated as null.
  String? get displayName {
    final value = _prefs.getString(_kDisplayName)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<void> setDisplayName(String? value) async {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_kDisplayName);
    } else {
      await _prefs.setString(_kDisplayName, trimmed);
    }
  }

  /// The session type the quick-log form starts on. Defaults to training so the
  /// fast path is unchanged until the user picks otherwise (CLAUDE.md §4).
  SessionType get defaultSessionType {
    final stored = _prefs.getString(_kDefaultSessionType);
    return stored == null
        ? SessionType.training
        : SessionType.fromStorage(stored);
  }

  Future<void> setDefaultSessionType(SessionType value) =>
      _prefs.setString(_kDefaultSessionType, value.storageValue);

  /// Player avatar customisation, persisted device-locally.
  /// Defaults to [AvatarConfig.defaultConfig] on first launch.
  AvatarConfig get avatarConfig {
    final json = _prefs.getString(_kAvatarConfig);
    if (json == null) return AvatarConfig.defaultConfig;
    try {
      return AvatarConfig.fromJsonString(json);
    } catch (_) {
      return AvatarConfig.defaultConfig;
    }
  }

  Future<void> setAvatarConfig(AvatarConfig config) =>
      _prefs.setString(_kAvatarConfig, config.toJsonString());
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
