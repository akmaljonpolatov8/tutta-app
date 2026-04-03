import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/profile_settings_repository.dart';

class LocalProfileSettingsRepository implements ProfileSettingsRepository {
  const LocalProfileSettingsRepository(this._storage);

  final SecureStorageService _storage;

  static const _pushNotificationsKey = 'settings_push_notifications';
  static const _bookingUpdatesKey = 'settings_booking_updates';
  static const _marketingUpdatesKey = 'settings_marketing_updates';
  static const _emailUpdatesKey = 'settings_email_updates';
  static const _chatPreviewKey = 'settings_chat_preview';
  static const _locationSuggestionsKey = 'settings_location_suggestions';
  static const _hostPhoneVisibleKey = 'settings_host_phone_visible';
  static const _biometricLockKey = 'settings_biometric_lock';
  static const _analyticsEnabledKey = 'settings_analytics_enabled';

  @override
  Future<ProfileSettings> load() async {
    final fallback = const ProfileSettings.defaults();
    return ProfileSettings(
      pushNotificationsEnabled: await _readBool(
        _pushNotificationsKey,
        fallback.pushNotificationsEnabled,
      ),
      bookingUpdatesEnabled: await _readBool(
        _bookingUpdatesKey,
        fallback.bookingUpdatesEnabled,
      ),
      marketingUpdatesEnabled: await _readBool(
        _marketingUpdatesKey,
        fallback.marketingUpdatesEnabled,
      ),
      emailUpdatesEnabled: await _readBool(
        _emailUpdatesKey,
        fallback.emailUpdatesEnabled,
      ),
      chatPreviewEnabled: await _readBool(
        _chatPreviewKey,
        fallback.chatPreviewEnabled,
      ),
      locationSuggestionsEnabled: await _readBool(
        _locationSuggestionsKey,
        fallback.locationSuggestionsEnabled,
      ),
      hostPhoneVisible: await _readBool(
        _hostPhoneVisibleKey,
        fallback.hostPhoneVisible,
      ),
      biometricLockEnabled: await _readBool(
        _biometricLockKey,
        fallback.biometricLockEnabled,
      ),
      analyticsEnabled: await _readBool(
        _analyticsEnabledKey,
        fallback.analyticsEnabled,
      ),
    );
  }

  @override
  Future<void> save(ProfileSettings settings) async {
    await Future.wait([
      _writeBool(_pushNotificationsKey, settings.pushNotificationsEnabled),
      _writeBool(_bookingUpdatesKey, settings.bookingUpdatesEnabled),
      _writeBool(_marketingUpdatesKey, settings.marketingUpdatesEnabled),
      _writeBool(_emailUpdatesKey, settings.emailUpdatesEnabled),
      _writeBool(_chatPreviewKey, settings.chatPreviewEnabled),
      _writeBool(_locationSuggestionsKey, settings.locationSuggestionsEnabled),
      _writeBool(_hostPhoneVisibleKey, settings.hostPhoneVisible),
      _writeBool(_biometricLockKey, settings.biometricLockEnabled),
      _writeBool(_analyticsEnabledKey, settings.analyticsEnabled),
    ]);
  }

  Future<bool> _readBool(String key, bool fallback) async {
    final raw = await _storage.readString(key);
    if (raw == null) {
      return fallback;
    }
    return raw == 'true';
  }

  Future<void> _writeBool(String key, bool value) {
    return _storage.writeString(key: key, value: value.toString());
  }
}
