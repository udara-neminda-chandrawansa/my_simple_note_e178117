import 'package:flutter/material.dart';
import 'database_handler.dart';
import 'note.dart';

void main() {
  runApp(const MySimpleNoteApp());
  print("*** App Started ***");
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late DatabaseHandler handler;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final notes = await handler.retrieveNotes();
    print("Number of notes fetched: ${notes.length}");
    setState(() {
      _notes = notes;
    });
  }

  void _addNote() async {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      print(
          "Adding note: Title - ${_titleController.text}, Content - ${_contentController.text}");
      Note newNote = Note(
        title: _titleController.text,
        text: _contentController.text,
      );
      int result = await handler.insertNote([newNote]);
      print("Number of notes inserted: $result");
      _titleController.clear();
      _contentController.clear();
      _refreshNotes();
    } else {
      print("Title or content is empty. Note not added.");
    }
  }

  void _editNote(int index) async {
    _titleController.text = _notes[index].title;
    _contentController.text = _notes[index].text;
    await _deleteNote(index);
  }

  Future<void> _deleteNote(int index) async {
    await handler.deleteNote(_notes[index].id!);
    _refreshNotes();
  }

  void _viewNoteDetails(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_notes[index].title),
          content: Text(_notes[index].text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
          Expanded(
            child: _notes.isNotEmpty
                ? ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          title: Text(_notes[index].title),
                          subtitle: Text(_notes[index].text),
                          onTap: () => _viewNoteDetails(index),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editNote(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No notes available.')),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.green[300],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
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
                      TextField(
                        controller: _contentController,
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
                          labelText: 'Enter note content...',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
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
