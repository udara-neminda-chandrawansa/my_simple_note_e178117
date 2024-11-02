import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'example.db'), // changed from example.db
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE note(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, text TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertNote(List<Note> notes) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var note in notes) {
      result = await db.insert('notes', note.toMap());
    }
    return result;
  }

  Future<List<Note>> retrieveNotes() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('notes');
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> deleteNote(int id) async {
    final db = await initializeDB();
    await db.delete(
      'notes',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
