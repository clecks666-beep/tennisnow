import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisnow/shared/data/app_preferences.dart';
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
}
