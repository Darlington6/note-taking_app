// import packages/modules

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:note_taking_app/data/models/note.dart';

// Centralized Firebase service class for Authentication & Firestore.
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user's UID (empty if not logged in)
  static String get currentUserId => _auth.currentUser?.uid ?? '';

  // Signup new user and handle errors gracefully
  static Future<Either<String, UserCredential>> signUpWithEmail(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const Left('Signup failed. No user found.');
      }

      // Store user profile in Firestore
      await saveUserProfile(credential.user!.uid, email);

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
    final userId = currentUserId;
    if (userId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a note for the current user
  static Future<String> addNote(Note note) async {
    final userId = currentUserId;
    final noteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc();

    await noteRef.set({
      'userId': userId,
      'text': note.text,
      'timestamp': note.timestamp ?? FieldValue.serverTimestamp(),
    });

    return noteRef.id;
  }

  // Update an existing note
  static Future<void> updateNote(String id, String text) async {
    final userId = currentUserId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id)
        .update({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete a note
  static Future<void> deleteNote(String id) async {
    final userId = currentUserId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id)
        .delete();
  }

  // Restore a deleted note using its full content (used in undo)
  static Future<void> restoreNote(Note note) async {
    final userId = currentUserId;
    final doc = _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id);

    await doc.set({
      'text': note.text,
      'timestamp': note.timestamp ?? FieldValue.serverTimestamp(),
      'userId': userId,
    });
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
      case 'invalid-credential':
        return 'Invalid credentials. This account may have been deleted or expired.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Save users' sign up credentials to Firestore
  static Future<void> saveUserProfile(String uid, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'password': 'Encrypted by FirebaseAuth', // Do not store raw passwords
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}