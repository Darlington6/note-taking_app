class Note {
  final String id;
  final String text;

  Note({required this.id, required this.text});

  // For future Firestore integration
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
    );
  }

  Note copyWith({String? text, required String id}) {
    return Note(
      id: id,
      text: text ?? this.text,
    );
  }
}