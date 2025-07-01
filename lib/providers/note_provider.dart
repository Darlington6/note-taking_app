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

  // Adds a new note, then notify UI to update.
  Future<void> addNote(String text) async {
    if (text.trim().isEmpty) return;

    isLoading = true;
    notifyListeners();

    await FirebaseService.addNote(text);
    isLoading = false;
    notifyListeners();
  }

  // Updates an existing note and notifies UI.
  Future<void> updateNote(String id, String newText) async {
    if (newText.trim().isEmpty) return;

    isLoading = true;
    notifyListeners();

    await FirebaseService.updateNote(id, newText);
    isLoading = false;
    notifyListeners();
  }

  // Deletes a note by ID and updates UI state.
  Future<void> deleteNote(String id) async {
    isLoading = true;
    notifyListeners();

    await FirebaseService.deleteNote(id);
    isLoading = false;
    notifyListeners();
  }
}