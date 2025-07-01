// import packages
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String text;
  final Timestamp? timestamp; // New field for sorting & display

  Note({
    required this.id,
    required this.text,
    this.timestamp,
  });

  // Convert Note to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp, // Include timestamp in map
    };
  }

  // Create a Note from Firestore map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'], // Extract timestamp from Firestore
    );
  }

  // Clone note with optional updated fields
  Note copyWith({String? id, String? text, Timestamp? timestamp}) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp, // Clone timestamp if needed
    );
  }
}