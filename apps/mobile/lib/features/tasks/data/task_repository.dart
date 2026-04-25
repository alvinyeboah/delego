import '../../../core/api/delego_json.dart';
import '../../../core/data/local_database.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import '../domain/task_item.dart';

class TaskRepository {
  TaskRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TaskItem>> getRemoteTasks(String workspaceId) async {
    final response = await _apiClient.get('/task/workspace/$workspaceId');
    final body = response.data;
    if (body is! List) {
      throw const FormatException('GET /task/workspace/:id must return a JSON array');
    }
    return body
        .map((e) => TaskItem.fromJson(asStringKeyedMap(e, 'GET /task/workspace tasks[]')))
        .toList();
  }

  Future<List<TaskItem>> getLocalTasks(String workspaceId) async {
    if (kIsWeb) return <TaskItem>[];
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
    if (kIsWeb) return;
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
    String? description,
    String priority = 'MEDIUM',
  }) async {
    final response = await _apiClient.post(
      '/task',
      data: {
        'workspaceId': workspaceId,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'priority': priority,
      },
    );
    return TaskItem.fromJson(asStringKeyedMap(response.data, 'POST /task'));
  }

  Future<TaskItem> updateTaskStatus({
    required String taskId,
    required String status,
    String? reason,
  }) async {
    final response = await _apiClient.patch(
      '/task/$taskId/status',
      data: {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return TaskItem.fromJson(asStringKeyedMap(response.data, 'PATCH /task/:id/status'));
  }

  Future<TaskItem> assignTask({
    required String taskId,
    required String assigneeUserId,
  }) async {
    final response = await _apiClient.patch(
      '/assignment/task/$taskId',
      data: {'assigneeUserId': assigneeUserId},
    );
    return TaskItem.fromJson(asStringKeyedMap(response.data, 'PATCH /assignment/task/:taskId'));
  }
}
