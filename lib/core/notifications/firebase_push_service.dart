import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options_env.dart';
import '../../features/notifications/application/notifications_controller.dart';
import '../../features/notifications/domain/models/push_notification_item.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      final options = FirebaseOptionsEnv.currentPlatform;
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (_) {
    return;
  }
}

class FirebasePushService {
  FirebasePushService._();

  static final FirebasePushService instance = FirebasePushService._();

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  String get setupMode =>
      FirebaseOptionsEnv.hasAnyEnvConfig ? 'env-options' : 'platform-config';

  Future<void> initialize(WidgetRef ref) async {
    if (_initialized) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        final options = FirebaseOptionsEnv.currentPlatform;
        if (options != null) {
          await Firebase.initializeApp(options: options);
        } else {
          await Firebase.initializeApp();
        }
      }

      final messenger = FirebaseMessaging.instance;

      await messenger.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      final token = await messenger.getToken();
      ref.read(pushFcmTokenProvider.notifier).state = token;
      ref.read(pushReadyProvider.notifier).state = true;

      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = messenger.onTokenRefresh.listen((token) {
        ref.read(pushFcmTokenProvider.notifier).state = token;
      });

      FirebaseMessaging.onMessage.listen((message) {
        unawaited(_onForegroundMessage(ref, message));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        unawaited(_onForegroundMessage(ref, message));
      });

      _initialized = true;
    } catch (_) {
      ref.read(pushReadyProvider.notifier).state = false;
      ref.read(pushFcmTokenProvider.notifier).state = null;
    }
  }

  Future<void> _onForegroundMessage(
    WidgetRef ref,
    RemoteMessage message,
  ) async {
    final data = message.data;
    final title =
        message.notification?.title ??
        (data['title'] as String?) ??
        'Notification';
    final body =
        message.notification?.body ??
        (data['body'] as String?) ??
        'You have a new update';
    final deepLink = (data['deepLink'] as String?) ?? '/home';
    final type = _mapType((data['type'] as String?) ?? 'system');

    await ref
        .read(notificationsControllerProvider)
        .pushLocal(title: title, body: body, type: type, deepLink: deepLink);
  }

  PushNotificationType _mapType(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final value in PushNotificationType.values) {
      if (value.name == normalized) {
        return value;
      }
    }
    return PushNotificationType.system;
  }
}
