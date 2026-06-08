import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/app_preferences.dart';
import '../../../../shared/domain/avatar/avatar_config.dart';

class AvatarConfigNotifier extends StateNotifier<AvatarConfig> {
  final AppPreferences _prefs;

  AvatarConfigNotifier(this._prefs) : super(_prefs.avatarConfig);

  Future<void> update(AvatarConfig config) async {
    state = config;
    await _prefs.setAvatarConfig(config);
  }
}

/// Provides the player's avatar config and exposes [AvatarConfigNotifier.update]
/// to persist changes. Public surface — may be read by any feature that needs
/// to display the player's avatar (achievements, session list, etc.).
final avatarConfigProvider =
    StateNotifierProvider<AvatarConfigNotifier, AvatarConfig>(
  (ref) => AvatarConfigNotifier(ref.read(appPreferencesProvider)),
);
