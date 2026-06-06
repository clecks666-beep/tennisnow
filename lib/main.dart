import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'shared/data/app_preferences.dart';

Future<void> main() async {
  // Load device-local preferences before the first frame so the onboarding gate
  // can be evaluated synchronously by the router.
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // ProviderScope hosts the AppDatabase and all providers for the app
      // lifetime; the SharedPreferences instance is injected here.
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TennisNowApp(),
    ),
  );
}
