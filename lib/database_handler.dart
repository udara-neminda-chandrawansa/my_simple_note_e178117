import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'note.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    // Use the ffi web factory on the web platform
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    String path;
    if (kIsWeb) {
      // Web-specific database path
      path = 'notes_db.db';
    } else {
      // Mobile/desktop path
      path = await getDatabasesPath();
      path = join(path, 'notes_db.db');
    }

    // Open the database and create table if it does not exist
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE IF NOT EXISTS note(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, text TEXT NOT NULL)",
        );
        print("Database and table 'note' created.");
      },
    );

    print("Database path: $path");
    print("Database opened successfully");
    return db;
  }

  Future<int> insertNote(List<Note> notes) async {
    final Database db = await initializeDB();
    int result = 0;
    for (var note in notes) {
      int rowId = await db.insert('note', note.toMap());
      print("Inserted note with ID: $rowId");
      result += rowId;
    }
    await db.close();
    return result;
  }

  Future<List<Note>> retrieveNotes() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('note');
    print("Retrieved notes from database: ${queryResult.length}");
    await db.close();
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> deleteNote(int id) async {
    final Database db = await initializeDB();
    await db.delete(
      'note',
      where: "id = ?",
      whereArgs: [id],
    );
    print("Deleted note with ID: $id");
    await db.close();
  }
}
