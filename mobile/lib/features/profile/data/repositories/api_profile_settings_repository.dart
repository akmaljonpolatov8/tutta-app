import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/profile_settings_repository.dart';
import 'local_profile_settings_repository.dart';

class ApiProfileSettingsRepository implements ProfileSettingsRepository {
  const ApiProfileSettingsRepository({
    required ApiClient apiClient,
    required LocalProfileSettingsRepository localRepository,
  }) : _apiClient = apiClient,
       _localRepository = localRepository;

  final ApiClient _apiClient;
  final LocalProfileSettingsRepository _localRepository;

  @override
  Future<ProfileSettings> load() async {
    final local = await _localRepository.load();
    final result = await _apiClient.get(ApiEndpoints.usersMePreferences);
    final loaded = result.when(
      success: (data) {
        final payload = ApiResponseParser.extractMap(data);
        return ProfileSettings.fromAnyMap(payload, fallback: local);
      },
      failure: (_) => local,
    );
    await _localRepository.save(loaded);
    return loaded;
  }

  @override
  Future<void> save(ProfileSettings settings) async {
    await _localRepository.save(settings);
    final payload = settings.toMap();
    final result = await _apiClient.patch(
      ApiEndpoints.usersMePreferences,
      data: payload,
    );
    result.when(success: (_) => null, failure: (_) => null);
  }
}
