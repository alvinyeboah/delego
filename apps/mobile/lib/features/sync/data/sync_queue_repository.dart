import '../../../core/data/local_database.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueRepository {
  Future<void> enqueue({required String id, required String payload}) async {
    final db = await LocalDatabase.instance();
    await db.insert(
      'sync_queue',
      {
        'id': id,
        'payload': payload,
        'createdAtIso': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
