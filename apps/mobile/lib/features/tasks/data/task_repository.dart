import '../../../core/data/local_database.dart';
import '../../../core/network/api_client.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/task_item.dart';

class TaskRepository {
  TaskRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TaskItem>> getRemoteTasks(String workspaceId) async {
    final response = await _apiClient.get('/task/workspace/$workspaceId');
    final body = response.data as List<dynamic>;
    return body
        .map((item) => TaskItem.fromMap(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<List<TaskItem>> getLocalTasks(String workspaceId) async {
    final db = await LocalDatabase.instance();
    final rows = await db.query(
      'tasks',
      where: 'workspaceId = ?',
      whereArgs: [workspaceId],
      orderBy: 'updatedAtIso DESC',
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<void> upsertTask(TaskItem task) async {
    final db = await LocalDatabase.instance();
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TaskItem> createRemoteTask({
    required String workspaceId,
    required String title,
    String priority = 'MEDIUM',
  }) async {
    final response = await _apiClient.post(
      '/task',
      data: {
        'workspaceId': workspaceId,
        'title': title,
        'priority': priority,
      },
    );
    return TaskItem.fromMap(Map<String, Object?>.from(response.data as Map));
  }
}
