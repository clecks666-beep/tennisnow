import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisnow/shared/data/app_preferences.dart';
import 'package:tennisnow/shared/domain/avatar/avatar_config.dart';
import 'package:tennisnow/shared/domain/session_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferences.onboardingComplete', () {
    test('defaults to false on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.onboardingComplete, isFalse);
    });

    test('persists once completed', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());

      await prefs.setOnboardingComplete(true);

      expect(prefs.onboardingComplete, isTrue);
    });

    test('reads an already-completed value', () async {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.onboardingComplete, isTrue);
    });
  });

  group('AppPreferences.displayName', () {
    test('is null when unset or blank, persists when set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.displayName, isNull);

      await prefs.setDisplayName('  Alex  ');
      expect(prefs.displayName, 'Alex'); // trimmed

      await prefs.setDisplayName('   ');
      expect(prefs.displayName, isNull); // blank clears
    });
  });

  group('AppPreferences.defaultSessionType', () {
    test('defaults to training', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.defaultSessionType, SessionType.training);
    });

    test('persists a chosen type', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      await prefs.setDefaultSessionType(SessionType.match);
      expect(prefs.defaultSessionType, SessionType.match);
    });
  });

  group('AppPreferences.avatarConfig', () {
    test('defaults to AvatarConfig.defaultConfig on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.avatarConfig, AvatarConfig.defaultConfig);
    });

    test('round-trips a customised config', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());

      const config = AvatarConfig(
        skinColor: 'ae5d29',
        hairStyle: 'long07',
        hairColor: 'f4d150',
        eyeStyle: 'variant06',
        mouthStyle: 'variant03',
        bgColor: '2e7d32',
      );
      await prefs.setAvatarConfig(config);

      expect(prefs.avatarConfig, config);
    });

    test('falls back to the default config if stored JSON is corrupt', () async {
      SharedPreferences.setMockInitialValues({'avatar_config': 'not-json'});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.avatarConfig, AvatarConfig.defaultConfig);
    });
  });
}
