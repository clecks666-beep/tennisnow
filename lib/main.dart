import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope hosts the AppDatabase and all providers for the app lifetime.
  runApp(const ProviderScope(child: TennisNowApp()));
}
