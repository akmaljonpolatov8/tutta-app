class ProfileSettings {
  const ProfileSettings({
    required this.pushNotificationsEnabled,
    required this.bookingUpdatesEnabled,
    required this.marketingUpdatesEnabled,
    required this.emailUpdatesEnabled,
    required this.chatPreviewEnabled,
    required this.locationSuggestionsEnabled,
    required this.hostPhoneVisible,
    required this.biometricLockEnabled,
    required this.analyticsEnabled,
  });

  const ProfileSettings.defaults()
    : pushNotificationsEnabled = true,
      bookingUpdatesEnabled = true,
      marketingUpdatesEnabled = false,
      emailUpdatesEnabled = true,
      chatPreviewEnabled = true,
      locationSuggestionsEnabled = true,
      hostPhoneVisible = false,
      biometricLockEnabled = false,
      analyticsEnabled = true;

  final bool pushNotificationsEnabled;
  final bool bookingUpdatesEnabled;
  final bool marketingUpdatesEnabled;
  final bool emailUpdatesEnabled;
  final bool chatPreviewEnabled;
  final bool locationSuggestionsEnabled;
  final bool hostPhoneVisible;
  final bool biometricLockEnabled;
  final bool analyticsEnabled;

  ProfileSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? bookingUpdatesEnabled,
    bool? marketingUpdatesEnabled,
    bool? emailUpdatesEnabled,
    bool? chatPreviewEnabled,
    bool? locationSuggestionsEnabled,
    bool? hostPhoneVisible,
    bool? biometricLockEnabled,
    bool? analyticsEnabled,
  }) {
    return ProfileSettings(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      bookingUpdatesEnabled:
          bookingUpdatesEnabled ?? this.bookingUpdatesEnabled,
      marketingUpdatesEnabled:
          marketingUpdatesEnabled ?? this.marketingUpdatesEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled ?? this.emailUpdatesEnabled,
      chatPreviewEnabled: chatPreviewEnabled ?? this.chatPreviewEnabled,
      locationSuggestionsEnabled:
          locationSuggestionsEnabled ?? this.locationSuggestionsEnabled,
      hostPhoneVisible: hostPhoneVisible ?? this.hostPhoneVisible,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  Map<String, bool> toMap() {
    return <String, bool>{
      'push_notifications_enabled': pushNotificationsEnabled,
      'booking_updates_enabled': bookingUpdatesEnabled,
      'marketing_updates_enabled': marketingUpdatesEnabled,
      'email_updates_enabled': emailUpdatesEnabled,
      'chat_preview_enabled': chatPreviewEnabled,
      'location_suggestions_enabled': locationSuggestionsEnabled,
      'host_phone_visible': hostPhoneVisible,
      'biometric_lock_enabled': biometricLockEnabled,
      'analytics_enabled': analyticsEnabled,
    };
  }

  factory ProfileSettings.fromAnyMap(
    Map<String, dynamic> payload, {
    ProfileSettings fallback = const ProfileSettings.defaults(),
  }) {
    bool read(String key, bool current) {
      final raw = payload[key];
      if (raw is bool) {
        return raw;
      }
      if (raw is String) {
        final normalized = raw.toLowerCase().trim();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
      if (raw is num) {
        return raw != 0;
      }
      return current;
    }

    return fallback.copyWith(
      pushNotificationsEnabled: read(
        'push_notifications_enabled',
        fallback.pushNotificationsEnabled,
      ),
      bookingUpdatesEnabled: read(
        'booking_updates_enabled',
        fallback.bookingUpdatesEnabled,
      ),
      marketingUpdatesEnabled: read(
        'marketing_updates_enabled',
        fallback.marketingUpdatesEnabled,
      ),
      emailUpdatesEnabled: read(
        'email_updates_enabled',
        fallback.emailUpdatesEnabled,
      ),
      chatPreviewEnabled: read(
        'chat_preview_enabled',
        fallback.chatPreviewEnabled,
      ),
      locationSuggestionsEnabled: read(
        'location_suggestions_enabled',
        fallback.locationSuggestionsEnabled,
      ),
      hostPhoneVisible: read('host_phone_visible', fallback.hostPhoneVisible),
      biometricLockEnabled: read(
        'biometric_lock_enabled',
        fallback.biometricLockEnabled,
      ),
      analyticsEnabled: read('analytics_enabled', fallback.analyticsEnabled),
    );
  }
}
