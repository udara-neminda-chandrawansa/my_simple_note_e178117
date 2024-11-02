import 'package:flutter/material.dart';

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
  final List<String> _notes = [];
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _notes.add(_controller.text);
      });
      _controller.clear();
    }
  }

  void _editNote(int index) {
    _controller.text = _notes[index];
    _deleteNote(index);
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _viewNoteDetails(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('View Note'),
          content: Text(_notes[index]),
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
        title: const Text('MySimpleNote'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your note...',
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(4.8),
                ),
                Container(
                  color: Colors.blue, // Set background color
                  padding:
                      const EdgeInsets.all(3.8), // Add padding for square shape
                  child: IconButton(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    color: Colors.white, // Icon color
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_notes[index]),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
