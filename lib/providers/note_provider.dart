// import packages/modules
import 'package:flutter/material.dart';
import '../data/models/note.dart';

// NoteProvider handles all note-related state and logic.
// I will later add Firestore integration and CRUD logic.
class NoteProvider extends ChangeNotifier {
  // List to hold notes locally
  final List<Note> _notes = [];

  // Getter for external widgets to access notes
  List<Note> get notes => _notes;

  // Adds a new note (actual Firestore integration will come later)
  void addNote(Note note) {
    _notes.add(note);
    notifyListeners(); // Notifies listeners of state change
  }

  // Updates an existing note
  void updateNote(String id, String newText) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(text: newText);
      notifyListeners();
    }
  }

  // Deletes a note by ID
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
