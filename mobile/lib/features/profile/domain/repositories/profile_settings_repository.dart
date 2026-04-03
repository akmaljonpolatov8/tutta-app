import '../models/profile_settings.dart';

abstract interface class ProfileSettingsRepository {
  Future<ProfileSettings> load();

  Future<void> save(ProfileSettings settings);
}
