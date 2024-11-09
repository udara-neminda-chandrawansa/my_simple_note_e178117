class Note {
  // Attributes: 'id' is optional, while 'title' and 'text' are required
  final int? id;
  final String title;
  final String text;

  // Constructor
  Note({this.id, required this.title, required this.text});

  // Named constructor to create a Note instance from a Map
  Note.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        title = res["title"],
        text = res["text"];

  // Method to convert a Note instance to a Map, making it compatible for database insertion
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
    };
  }
}
