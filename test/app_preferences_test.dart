import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tennisnow/shared/data/app_preferences.dart';

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
}
