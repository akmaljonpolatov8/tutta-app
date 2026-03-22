import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseOptionsEnv {
  const FirebaseOptionsEnv._();

  static const String androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String androidMessagingSenderId = String.fromEnvironment(
    'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
  );
  static const String androidProjectId = String.fromEnvironment(
    'FIREBASE_ANDROID_PROJECT_ID',
  );
  static const String androidStorageBucket = String.fromEnvironment(
    'FIREBASE_ANDROID_STORAGE_BUCKET',
  );

  static const String iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const String iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const String iosMessagingSenderId = String.fromEnvironment(
    'FIREBASE_IOS_MESSAGING_SENDER_ID',
  );
  static const String iosProjectId = String.fromEnvironment(
    'FIREBASE_IOS_PROJECT_ID',
  );
  static const String iosStorageBucket = String.fromEnvironment(
    'FIREBASE_IOS_STORAGE_BUCKET',
  );
  static const String iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );

  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const String webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String webMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
  );
  static const String webProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
  );
  static const String webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const String webStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
  );
  static const String webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );

  static bool get hasAnyEnvConfig {
    return androidApiKey.isNotEmpty ||
        iosApiKey.isNotEmpty ||
        webApiKey.isNotEmpty;
  }

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      if (!_webValid) {
        return null;
      }

      return FirebaseOptions(
        apiKey: webApiKey,
        appId: webAppId,
        messagingSenderId: webMessagingSenderId,
        projectId: webProjectId,
        authDomain: webAuthDomain.isEmpty ? null : webAuthDomain,
        storageBucket: webStorageBucket.isEmpty ? null : webStorageBucket,
        measurementId: webMeasurementId.isEmpty ? null : webMeasurementId,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (!_androidValid) {
          return null;
        }
        return FirebaseOptions(
          apiKey: androidApiKey,
          appId: androidAppId,
          messagingSenderId: androidMessagingSenderId,
          projectId: androidProjectId,
          storageBucket: androidStorageBucket.isEmpty
              ? null
              : androidStorageBucket,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (!_iosValid) {
          return null;
        }
        return FirebaseOptions(
          apiKey: iosApiKey,
          appId: iosAppId,
          messagingSenderId: iosMessagingSenderId,
          projectId: iosProjectId,
          storageBucket: iosStorageBucket.isEmpty ? null : iosStorageBucket,
          iosBundleId: iosBundleId.isEmpty ? null : iosBundleId,
        );
      default:
        return null;
    }
  }

  static bool get _androidValid {
    return androidApiKey.isNotEmpty &&
        androidAppId.isNotEmpty &&
        androidMessagingSenderId.isNotEmpty &&
        androidProjectId.isNotEmpty;
  }

  static bool get _iosValid {
    return iosApiKey.isNotEmpty &&
        iosAppId.isNotEmpty &&
        iosMessagingSenderId.isNotEmpty &&
        iosProjectId.isNotEmpty;
  }

  static bool get _webValid {
    return webApiKey.isNotEmpty &&
        webAppId.isNotEmpty &&
        webMessagingSenderId.isNotEmpty &&
        webProjectId.isNotEmpty;
  }
}
