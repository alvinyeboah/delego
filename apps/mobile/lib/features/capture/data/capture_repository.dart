import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class CaptureRepository {
  CaptureRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CaptureSessionDto> createSession({
    required String workspaceId,
    required String imageStorageKey,
    String? createdById,
    double? latitude,
    double? longitude,
    String? deviceModel,
    String? capturedAtIso,
  }) async {
    final response = await _apiClient.post(
      '/capture/session',
      data: {
        'workspaceId': workspaceId,
        'imageStorageKey': imageStorageKey,
        'createdById': ?createdById,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'deviceModel': ?deviceModel,
        'capturedAt': ?capturedAtIso,
      },
    );
    return CaptureSessionDto.fromJson(asStringKeyedMap(response.data, 'POST /capture/session'));
  }

  /// Proxies to the worker OCR pipeline via the API (`POST /capture/pipeline/run`).
  Future<Map<String, dynamic>> runWorkerPipeline({required String storageKey}) async {
    final response = await _apiClient.post(
      '/capture/pipeline/run',
      data: {'storageKey': storageKey},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'result': data};
  }
}
