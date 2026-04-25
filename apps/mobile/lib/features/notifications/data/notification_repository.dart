import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<NotificationDto>> listForUser(String userId) async {
    final response = await _apiClient.get('/notification/$userId');
    final body = response.data;
    if (body is! List) {
      throw const FormatException('GET /notification/:userId must return a JSON array');
    }
    return body
        .map((e) => NotificationDto.fromJson(asStringKeyedMap(e, 'GET /notification[]')))
        .toList();
  }

  Future<NotificationDto> create({
    required String userId,
    required String title,
    required String body,
  }) async {
    final response = await _apiClient.post(
      '/notification',
      data: {'userId': userId, 'title': title, 'body': body},
    );
    return NotificationDto.fromJson(asStringKeyedMap(response.data, 'POST /notification'));
  }
}
