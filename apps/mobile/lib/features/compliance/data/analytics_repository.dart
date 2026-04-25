import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DomainEventOutboxDto> publish({
    required String tenantId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post(
      '/analytics-event',
      data: {
        'tenantId': tenantId,
        'eventType': eventType,
        'payload': payload,
      },
    );
    return DomainEventOutboxDto.fromJson(asStringKeyedMap(response.data, 'POST /analytics-event'));
  }
}
