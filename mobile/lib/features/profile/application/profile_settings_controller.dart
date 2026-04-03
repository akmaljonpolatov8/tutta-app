import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/runtime_flags.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/repositories/api_profile_settings_repository.dart';
import '../data/repositories/fake_profile_settings_repository.dart';
import '../data/repositories/local_profile_settings_repository.dart';
import '../domain/models/profile_settings.dart';
import '../domain/repositories/profile_settings_repository.dart';

class ProfileSettingsState {
  const ProfileSettingsState({
    required this.settings,
    required this.hydrated,
    required this.syncing,
  });

  const ProfileSettingsState.initial()
    : settings = const ProfileSettings.defaults(),
      hydrated = false,
      syncing = false;

  final ProfileSettings settings;
  final bool hydrated;
  final bool syncing;

  bool get pushNotificationsEnabled => settings.pushNotificationsEnabled;
  bool get bookingUpdatesEnabled => settings.bookingUpdatesEnabled;
  bool get marketingUpdatesEnabled => settings.marketingUpdatesEnabled;
  bool get emailUpdatesEnabled => settings.emailUpdatesEnabled;
  bool get chatPreviewEnabled => settings.chatPreviewEnabled;
  bool get locationSuggestionsEnabled => settings.locationSuggestionsEnabled;
  bool get hostPhoneVisible => settings.hostPhoneVisible;
  bool get biometricLockEnabled => settings.biometricLockEnabled;
  bool get analyticsEnabled => settings.analyticsEnabled;

  ProfileSettingsState copyWith({
    ProfileSettings? settings,
    bool? hydrated,
    bool? syncing,
  }) {
    return ProfileSettingsState(
      settings: settings ?? this.settings,
      hydrated: hydrated ?? this.hydrated,
      syncing: syncing ?? this.syncing,
    );
  }
}

final localProfileSettingsRepositoryProvider =
    Provider<LocalProfileSettingsRepository>((ref) {
      return LocalProfileSettingsRepository(
        ref.watch(secureStorageServiceProvider),
      );
    });

final profileSettingsRepositoryProvider = Provider<ProfileSettingsRepository>((
  ref,
) {
  final local = ref.watch(localProfileSettingsRepositoryProvider);
  if (RuntimeFlags.useFakeAuth) {
    return FakeProfileSettingsRepository(local);
  }
  return ApiProfileSettingsRepository(
    apiClient: ref.watch(apiClientProvider),
    localRepository: local,
  );
});

class ProfileSettingsController extends StateNotifier<ProfileSettingsState> {
  ProfileSettingsController(this._repository)
    : super(const ProfileSettingsState.initial()) {
    _restore();
  }

  final ProfileSettingsRepository _repository;

  Future<void> setPushNotifications(bool value) {
    final next = state.settings.copyWith(pushNotificationsEnabled: value);
    return _save(next);
  }

  Future<void> setBookingUpdates(bool value) {
    final next = state.settings.copyWith(bookingUpdatesEnabled: value);
    return _save(next);
  }

  Future<void> setMarketingUpdates(bool value) {
    final next = state.settings.copyWith(marketingUpdatesEnabled: value);
    return _save(next);
  }

  Future<void> setEmailUpdates(bool value) {
    final next = state.settings.copyWith(emailUpdatesEnabled: value);
    return _save(next);
  }

  Future<void> setChatPreview(bool value) {
    final next = state.settings.copyWith(chatPreviewEnabled: value);
    return _save(next);
  }

  Future<void> setLocationSuggestions(bool value) {
    final next = state.settings.copyWith(locationSuggestionsEnabled: value);
    return _save(next);
  }

  Future<void> setHostPhoneVisible(bool value) {
    final next = state.settings.copyWith(hostPhoneVisible: value);
    return _save(next);
  }

  Future<void> setBiometricLock(bool value) {
    final next = state.settings.copyWith(biometricLockEnabled: value);
    return _save(next);
  }

  Future<void> setAnalyticsEnabled(bool value) {
    final next = state.settings.copyWith(analyticsEnabled: value);
    return _save(next);
  }

  Future<void> resetToDefault() {
    return _save(const ProfileSettings.defaults());
  }

  Future<void> _restore() async {
    final restored = await _repository.load();
    state = state.copyWith(settings: restored, hydrated: true, syncing: false);
  }

  Future<void> _save(ProfileSettings settings) async {
    state = state.copyWith(settings: settings, hydrated: true, syncing: true);
    await _repository.save(settings);
    state = state.copyWith(syncing: false);
  }
}

final profileSettingsControllerProvider =
    StateNotifierProvider<ProfileSettingsController, ProfileSettingsState>((
      ref,
    ) {
      return ProfileSettingsController(
        ref.watch(profileSettingsRepositoryProvider),
      );
    });
