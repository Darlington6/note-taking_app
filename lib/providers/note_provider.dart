// import packages/modules
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_taking_app/data/models/note.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';

// Provider to manage state and interactions with notes (CRUD).
class NoteProvider extends ChangeNotifier {
  // Private list of notes
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  bool isLoading = false;
  StreamSubscription<List<Note>>? _notesSubscription;

  // Start listening to the user's notes from Firestore.
  Future<void> listenToNotes() async {
    isLoading = true;
    notifyListeners(); // Notify loading state

    // Delay to ensure FirebaseAuth has initialized the user
    await Future.delayed(const Duration(milliseconds: 300));

    final userId = FirebaseService.currentUserId;
    if (userId.isEmpty) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // Cancel any existing listener before starting a new one
    _notesSubscription?.cancel();

    _notesSubscription = FirebaseService.getUserNotesStream().listen((fetchedNotes) {
      _notes = List.from(fetchedNotes)
        ..sort((a, b) {
          final aTime = a.timestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);
          final bTime = b.timestamp ?? Timestamp.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      isLoading = false;
      notifyListeners();
    });
  }

  // Call this when logging out to stop listening to notes
  void cancelNoteSubscription() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  // Adds a new note (no need to update list manually, Firestore stream will handle it)
  Future<void> addNote(Note note) async {
    await FirebaseService.addNote(note);
  }

  // Updates an existing note (Firestore stream will auto-update UI)
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

  @override
  void dispose() {
    _notesSubscription?.cancel(); // Clean up the stream
    super.dispose();
  }
}