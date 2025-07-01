// lib/core/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:note_taking_app/core/constants.dart';
import 'package:note_taking_app/data/models/note.dart';

// Centralized Firebase service class for Authentication & Firestore.
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user's UID (empty if not logged in)
  static String get currentUserId => _auth.currentUser?.uid ?? '';

  // Signup new user and handle errors gracefully
  static Future<Either<String, UserCredential>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthError(e));
    } catch (_) {
      return const Left('An unexpected error occurred during signup.');
    }
  }

  // Login existing user and handle errors gracefully
  static Future<Either<String, UserCredential>> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthError(e));
    } catch (_) {
      return const Left('An unexpected error occurred during login.');
    }
  }

  // Logout current user
  static Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Get stream of notes for the current user, ordered by timestamp
  static Stream<List<Note>> getUserNotesStream() {
    return _firestore
        .collection(kNotesCollection)
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Note.fromMap(doc.data()).copyWith(id: doc.id)).toList());
  }

  // Add a note for the current user
  static Future<String?> addNote(String text) async {
    try {
      final doc = await _firestore.collection(kNotesCollection).add({
        'text': text,
        'userId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing note
  static Future<void> updateNote(String id, String text) async {
    await _firestore.collection(kNotesCollection).doc(id).update({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete a note
  static Future<void> deleteNote(String id) async {
    await _firestore.collection(kNotesCollection).doc(id).delete();
  }

  // Handles FirebaseAuth error codes into readable messages
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}