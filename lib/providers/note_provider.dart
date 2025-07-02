// import packages/modules
import 'package:flutter/material.dart';
import 'package:note_taking_app/data/models/note.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';

// Provider to manage state and interactions with notes (CRUD).
class NoteProvider extends ChangeNotifier {
  // Private list of notes
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  bool isLoading = false;

  // Start listening to the user's notes from Firestore.
  void listenToNotes() {
    isLoading = true;
    notifyListeners(); // Notify loading state

    FirebaseService.getUserNotesStream().listen((fetchedNotes) {
      _notes = fetchedNotes;
      isLoading = false;
      notifyListeners();
    });
  }

  // Adds a new note (no need to update list manually, Firestore stream will handle it)
  Future<void> addNote(Note note) async {
    await FirebaseService.addNote(note);
  }

  // Updates an existing note (FireStore stream will auto-update UI)
  Future<void> updateNote(String id, String newText) async {
    if (newText.trim().isEmpty) return;
    await FirebaseService.updateNote(id, newText);
  }

  // Deletes a note by ID (UI will reflect via stream)
  Future<void> deleteNote(String id) async {
    await FirebaseService.deleteNote(id);
  }

  // Restores a deleted note (undo functionality)
  Future<void> restoreNote(Note note) async {
    await FirebaseService.restoreNote(note);
  }
}