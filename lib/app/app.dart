import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../design_system/theme/app_theme.dart';
import 'router.dart';

/// Root app widget. Wires the single theme and the router; no logic here.
class TennisNowApp extends StatelessWidget {
  const TennisNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRouter.router,
    );
  }
}
