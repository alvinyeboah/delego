import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class AuditRepository {
  AuditRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AuditLogDto>> listForTenant(String tenantId) async {
    final response = await _apiClient.get('/audit/$tenantId');
    final body = response.data;
    if (body is! List) {
      throw const FormatException('GET /audit/:tenantId must return a JSON array');
    }
    return body
        .map((e) => AuditLogDto.fromJson(asStringKeyedMap(e, 'GET /audit[]')))
        .toList();
  }

  Future<AuditLogDto> log({
    required String tenantId,
    String? actorUserId,
    required String action,
    required String resource,
    String? resourceId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiClient.post(
      '/audit',
      data: {
        'tenantId': tenantId,
        'actorUserId': ?actorUserId,
        'action': action,
        'resource': resource,
        'resourceId': ?resourceId,
        'metadata': ?metadata,
      },
    );
    return AuditLogDto.fromJson(asStringKeyedMap(response.data, 'POST /audit'));
  }
}
