import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;
  static final Map<String, String> _webMeta = <String, String>{};

  static const int _version = 2;

  static Future<Database> instance() async {
    if (kIsWeb) {
      throw UnsupportedError('LocalDatabase.instance is not available on web');
    }
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'delego.db');
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            workspaceId TEXT NOT NULL,
            assigneeUserId TEXT,
            version INTEGER NOT NULL DEFAULT 1,
            updatedAtIso TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_queue(
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            createdAtIso TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_meta(
            k TEXT PRIMARY KEY,
            v TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN description TEXT');
          await db.execute("UPDATE tasks SET description = '' WHERE description IS NULL");
          await db.execute('ALTER TABLE tasks ADD COLUMN assigneeUserId TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN version INTEGER');
          await db.execute('UPDATE tasks SET version = 1 WHERE version IS NULL');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS sync_meta(
              k TEXT PRIMARY KEY,
              v TEXT NOT NULL
            )
          ''');
        }
      },
    );
    return _db!;
  }

  static Future<String?> readMeta(String key) async {
    if (kIsWeb) {
      return _webMeta[key];
    }
    final db = await instance();
    final rows = await db.query('sync_meta', where: 'k = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['v'] as String?;
  }

  static Future<void> writeMeta(String key, String value) async {
    if (kIsWeb) {
      _webMeta[key] = value;
      return;
    }
    final db = await instance();
    await db.insert(
      'sync_meta',
      {'k': key, 'v': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
