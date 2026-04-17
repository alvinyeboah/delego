import '../../../core/data/local_database.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/task_item.dart';

class TaskRepository {
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
}
