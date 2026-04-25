import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class DeviceTokenRepository {
  DeviceTokenRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DeviceTokenDto> register({required String token, required String platform}) async {
    final response = await _apiClient.post(
      '/device-tokens',
      data: {'token': token, 'platform': platform},
    );
    return DeviceTokenDto.fromJson(asStringKeyedMap(response.data, 'POST /device-tokens'));
  }

  Future<List<DeviceTokenDto>> list() async {
    final response = await _apiClient.get('/device-tokens');
    final raw = response.data;
    if (raw is! List) {
      throw const FormatException('GET /device-tokens expected a JSON array');
    }
    return raw
        .map((e) => DeviceTokenDto.fromJson(asStringKeyedMap(e, 'GET /device-tokens[]')))
        .toList();
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/device-tokens/$id');
  }
}
