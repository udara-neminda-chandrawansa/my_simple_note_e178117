import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    print("Database path: $path");
    return openDatabase(
      join(path, 'notes_db.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE IF NOT EXISTS note(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, text TEXT NOT NULL)",
        );
        print("Database created with table note");
      },
      version: 1,
    );
  }

  Future<int> insertNote(List<Note> notes) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var note in notes) {
      int rowId = await db.insert('note', note.toMap());
      print("Inserted note with ID: $rowId");
      result += rowId;
    }
    return result;
  }

  Future<List<Note>> retrieveNotes() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('note');
    print("Retrieved notes from database: ${queryResult.length}");
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> deleteNote(int id) async {
    final db = await initializeDB();
    await db.delete(
      'note',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
