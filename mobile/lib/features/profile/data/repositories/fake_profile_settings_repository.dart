import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/profile_settings_repository.dart';
import 'local_profile_settings_repository.dart';

class FakeProfileSettingsRepository implements ProfileSettingsRepository {
  const FakeProfileSettingsRepository(this._localRepository);

  final LocalProfileSettingsRepository _localRepository;

  @override
  Future<ProfileSettings> load() => _localRepository.load();

  @override
  Future<void> save(ProfileSettings settings) =>
      _localRepository.save(settings);
}
