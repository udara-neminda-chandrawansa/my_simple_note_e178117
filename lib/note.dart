class Note {
  final int? id;
  final String title;
  final String text;

  Note({this.id, required this.title, required this.text});
  Note.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        title = res["title"],
        text = res["text"];
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
    };
  }
}
