import 'package:flutter/material.dart';
import 'database_handler.dart';
import 'note.dart';

void main() {
  runApp(const MySimpleNoteApp());
}

class MySimpleNoteApp extends StatelessWidget {
  const MySimpleNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySimpleNote',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyNotesPage(),
    );
  }
}

class MyNotesPage extends StatefulWidget {
  const MyNotesPage({super.key});

  @override
  State<MyNotesPage> createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  // text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // database handler obj
  late DatabaseHandler handler;
  // notes list
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    // initiate database handler obj
    handler = DatabaseHandler();
    // load all notes to home
    _refreshNotes();
  }

  // Method to load/refresh all notes
  Future<void> _refreshNotes() async {
    // get all notes from db
    final notes = await handler.retrieveNotes();
    setState(() { // put notes in home
      _notes = notes;
    });
  }

  // Method to add notes to the database
  void _addNote() async {
    // Validate user input in title and content text fields
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      // create a new note object
      Note newNote = Note(
        title: _titleController.text,
        text: _contentController.text,
      );
      // insert the new note object to database using `insertNote` method
      await handler.insertNote([newNote]);
      // clear input fields
      _titleController.clear();
      _contentController.clear();
      // refresh note list
      _refreshNotes();
    }
  }

  // Method to edit notes
  void _editNote(int index) async {
    _titleController.text = _notes[index].title;
    _contentController.text = _notes[index].text;
    await _deleteNote(index);
  }

  // Method to delete notes
  Future<void> _deleteNote(int index) async {
    // provide note id of the note that needs deleting to the `deleteNote` method
    await handler.deleteNote(_notes[index].id!);
    // refresh note list
    _refreshNotes();
  }

  // Method to read a note
  void _viewNoteDetails(Note note) {
    Navigator.push( // open a new screen
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple Note'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[300],
      ),
      body: Column(
        children: [
          Expanded( // in this expanded section, display notes from `_notes` list
            child: _notes.isNotEmpty
                ? ListView.builder( // use a list view to display notes
                    itemCount: _notes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card( // use a card to display a single note
                        child: ListTile(
                          title: Text(_notes[index].title), // set note title as title
                          subtitle: Text( // set note text as subtitle
                            _notes[index].text.length > 50 // if note text length > 50
                                ? '${_notes[index].text.substring(0, 50)}...' // use only first 50 characters
                                : _notes[index].text, // else show all text
                          ),
                          onTap: () => _viewNoteDetails(_notes[index]), // open `_viewNoteDetails` to display note
                          trailing: Row( // controls to delete & update
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton( // edit btn
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editNote(index), // call `_editNote` method to edit note
                              ),
                              IconButton( // update btn
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(index), // call `_deleteNote` method to delete note
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No notes available.')), // if `_notes` empty, display this
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.green[300],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField( // note title text field
                        controller: _titleController,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          labelText: 'Enter note title...',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField( // note content text area
                        controller: _contentController,
                        cursorColor: Colors.white,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          labelText: 'Enter note content...',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0), // space between text fields and add button
                Container( // container for add button
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton( // add button
                    onPressed: _addNote,
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// this screen is used to display a single note each time opened
class NoteDetailPage extends StatelessWidget {
  final Note note; // the note object that is displayed
  // this page requires the above note object
  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title), // set note title as app bar title
        backgroundColor: Colors.green[300],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // go back button
          onPressed: () {
            Navigator.pop(context); // go back to home
          },
        ),
      ),
      body: SingleChildScrollView( // scrollable container
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text( // note content
              note.text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
