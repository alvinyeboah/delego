import '../../../core/data/local_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

class SyncQueueRepository {
  static final List<Map<String, Object?>> _webQueue = <Map<String, Object?>>[];

  Future<void> enqueue({required String id, required String payload}) async {
    if (kIsWeb) {
      _webQueue.removeWhere((row) => row['id'] == id);
      _webQueue.add({
        'id': id,
        'payload': payload,
        'createdAtIso': DateTime.now().toIso8601String(),
      });
      return;
    }
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

  Future<List<Map<String, Object?>>> pending() async {
    if (kIsWeb) {
      _webQueue.sort(
        (a, b) => (a['createdAtIso'] as String).compareTo(b['createdAtIso'] as String),
      );
      return List<Map<String, Object?>>.from(_webQueue);
    }
    final db = await LocalDatabase.instance();
    return db.query('sync_queue', orderBy: 'createdAtIso ASC');
  }

  Future<void> remove(String id) async {
    if (kIsWeb) {
      _webQueue.removeWhere((row) => row['id'] == id);
      return;
    }
    final db = await LocalDatabase.instance();
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      _webQueue.clear();
      return;
    }
    final db = await LocalDatabase.instance();
    await db.delete('sync_queue');
  }
}
