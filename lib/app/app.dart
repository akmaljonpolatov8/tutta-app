import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/firebase_push_service.dart';
import '../features/notifications/application/notifications_controller.dart';
import 'l10n/l10n.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class TuttaApp extends ConsumerStatefulWidget {
  const TuttaApp({super.key});

  @override
  ConsumerState<TuttaApp> createState() => _TuttaAppState();
}

class _TuttaAppState extends ConsumerState<TuttaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebasePushService.instance.initialize(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    ref.watch(notificationsAuthScopeSyncProvider);
    ref.watch(notificationsPushSyncProvider);

    return MaterialApp.router(
      title: 'Tutta',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
