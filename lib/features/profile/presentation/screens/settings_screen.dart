import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/firebase_push_service.dart';
import '../../../notifications/application/notifications_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushReady = ref.watch(pushReadyProvider);
    final token = ref.watch(pushFcmTokenProvider);
    final pushSyncError = ref.watch(pushSyncErrorProvider);
    final setupMode = FirebasePushService.instance.setupMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.language_outlined),
            title: Text('Language'),
            subtitle: Text('Uzbek / Russian / English'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            subtitle: Text('Push and in-app preferences'),
          ),
          ListTile(
            leading: Icon(
              pushReady ? Icons.check_circle_outline : Icons.error_outline,
              color: pushReady ? Colors.green : Colors.orange,
            ),
            title: const Text('Firebase push status'),
            subtitle: Text(
              pushReady
                  ? 'Configured and active'
                  : 'Not configured yet (check Firebase project files)',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('Firebase setup mode'),
            subtitle: Text(
              setupMode == 'env-options'
                  ? 'Dart define based Firebase options'
                  : 'Platform config files (google-services/plist)',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: const Text('FCM Token'),
            subtitle: Text(
              token == null || token.isEmpty
                  ? 'Token not available yet'
                  : token,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (pushSyncError != null && pushSyncError.isNotEmpty)
            ListTile(
              leading: const Icon(
                Icons.sync_problem_outlined,
                color: Colors.red,
              ),
              title: const Text('Push sync error'),
              subtitle: Text(
                pushSyncError,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy'),
            subtitle: Text('Data and visibility settings'),
          ),
        ],
      ),
    );
  }
}
