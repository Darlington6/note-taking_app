// import packages/modules
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/note.dart';

// NoteProvider handles Firestore CRUD for notes.
class NoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  // Fetch all notes for the current user
  Future<void> fetchNotes() async {
    try {
      final snapshot = await _firestore.collection('notes').get();

      _notes = snapshot.docs.map((doc) {
        return Note.fromMap(doc.data()).copyWith(id: doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }
  }

  // Add a new note to Firestore
  Future<void> addNote(String text) async {
    try {
      final doc = await _firestore.collection('notes').add({'text': text});
      _notes.add(Note(id: doc.id, text: text));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  // Update an existing note in Firestore
  Future<void> updateNote(String id, String newText) async {
    try {
      await _firestore.collection('notes').doc(id).update({'text': newText});
      final index = _notes.indexWhere((note) => note.id == id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(text: newText, id: '');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  // Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    try {
      await _firestore.collection('notes').doc(id).delete();
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
}