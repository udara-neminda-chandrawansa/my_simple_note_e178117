import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'note.dart';

class DatabaseHandler {
  static Database? _database;

  // Singleton pattern to ensure only one instance of the database
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initializeDB();
    return _database!;
  }

  Future<Database> initializeDB() async {
    // Use the ffi web factory on the web platform
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    String path; // initiate database path var
    if (kIsWeb) {
      // Web-specific database path (for web platforms, this is the db path)
      path = 'notes_db.db';
    } else {
      // Mobile/desktop path (for mobile/desktop platforms, this is the db path)
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
      },
    );
    return db;
  }

  // Method to insert multiple notes into the database
  Future<void> insertNote(List<Note> notes) async {
    final Database db = await database;

    await db.transaction((txn) async {
      for (var note in notes) {
        await txn.insert('note', note.toMap()); // Insert each note
      }
    });
  }

  // Method to retrieve all notes from the database
  Future<List<Note>> retrieveNotes() async {
    final db = await database;
    final List<Map<String, Object?>> queryResult =
        await db.query('note'); // Query all notes
    return queryResult
        .map((e) => Note.fromMap(e))
        .toList(); // Convert map to List<Note>
  }

  // Method to delete a note by ID
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'note',
      where: "id = ?", // Specify note ID to delete
      whereArgs: [id], // Provide the ID as an argument
    );
  }
}
