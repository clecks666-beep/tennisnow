import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/app_preferences.dart';
import '../../../../shared/domain/session_type.dart';

/// Immutable settings state surfaced to the UI.
class SettingsState {
  final String? displayName;
  final SessionType defaultSessionType;

  const SettingsState({
    required this.displayName,
    required this.defaultSessionType,
  });

  SettingsState copyWith({
    String? displayName,
    bool clearDisplayName = false,
    SessionType? defaultSessionType,
  }) {
    return SettingsState(
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      defaultSessionType: defaultSessionType ?? this.defaultSessionType,
    );
  }
}

/// Holds device-local settings reactively and persists changes to
/// [AppPreferences]. A Notifier (not just the plain prefs object) so the UI —
/// the Settings screen, the personalized greeting, and the log form's default —
/// rebuilds when a setting changes.
class SettingsController extends Notifier<SettingsState> {
  AppPreferences get _prefs => ref.read(appPreferencesProvider);

  @override
  SettingsState build() {
    final prefs = _prefs;
    return SettingsState(
      displayName: prefs.displayName,
      defaultSessionType: prefs.defaultSessionType,
    );
  }

  Future<void> setDisplayName(String? value) async {
    await _prefs.setDisplayName(value);
    state = SettingsState(
      displayName: _prefs.displayName, // re-read so empty -> null is consistent
      defaultSessionType: state.defaultSessionType,
    );
  }

  Future<void> setDefaultSessionType(SessionType type) async {
    await _prefs.setDefaultSessionType(type);
    state = state.copyWith(defaultSessionType: type);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
