import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'delego.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            workspaceId TEXT NOT NULL,
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
      },
    );
    return _db!;
  }
}
