import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../design_system/theme/app_theme.dart';
import 'router.dart';

/// Root app widget. Wires the single theme and the router; no logic here.
class TennisNowApp extends ConsumerWidget {
  const TennisNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
