import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';
import '../../tasks/domain/task_item.dart';

class SyncPullResult {
  SyncPullResult({required this.tasks, required this.checkpointIso});

  final List<TaskItem> tasks;
  final String checkpointIso;
}

class SyncRepository {
  SyncRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SyncPullResult> pull({
    required String workspaceId,
    String? sinceIso,
  }) async {
    final response = await _apiClient.get(
      '/sync/pull',
      queryParameters: {
        'workspaceId': workspaceId,
        if (sinceIso != null && sinceIso.isNotEmpty) 'since': sinceIso,
      },
    );
    final body = asStringKeyedMap(response.data, 'GET /sync/pull');
    final tasksRaw = body['tasks'];
    if (tasksRaw is! List) {
      throw const FormatException('GET /sync/pull: "tasks" must be a JSON array');
    }
    final tasks = tasksRaw
        .map((e) => TaskItem.fromJson(asStringKeyedMap(e, 'GET /sync/pull tasks[]')))
        .toList();
    final checkpointIso = parseRequiredString(body['checkpoint'], 'GET /sync/pull checkpoint');
    return SyncPullResult(tasks: tasks, checkpointIso: checkpointIso);
  }

  Future<ConflictRecordDto> reportConflict({
    required String taskId,
    required String userId,
    required int localVersion,
    required int serverVersion,
    String? resolution,
  }) async {
    final response = await _apiClient.post(
      '/sync/conflict',
      data: {
        'taskId': taskId,
        'userId': userId,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
        if (resolution != null && resolution.isNotEmpty) 'resolution': resolution,
      },
    );
    return ConflictRecordDto.fromJson(asStringKeyedMap(response.data, 'POST /sync/conflict'));
  }
}
