import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class TuttaApp extends StatelessWidget {
  const TuttaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tutta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
