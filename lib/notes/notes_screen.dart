// import packages/modules
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_taking_app/core/constants.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';
import 'package:provider/provider.dart';

import '../../providers/note_provider.dart';
import '../../data/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isLoading = true;
  late NoteProvider _noteProvider;


  @override
  void initState() {
    super.initState();

    // Schedule note listening after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).listenToNotes();
      if (mounted) {
        setState(() => _isLoading = false); // Hide loader quickly
      }
    });
  }

  // Safely access the NoteProvider once the widget is in the widget tree.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteProvider = Provider.of<NoteProvider>(context, listen: false);   // This avoids context-related errors when calling Provider in dispose().
  }


  // Shows styled SnackBar
  void _showSnackBar(String message, {bool isSuccess = false, SnackBarAction? action}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.fixed,
      action: action,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Handle log out here
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog first
              Provider.of<NoteProvider>(context, listen: false).cancelNoteSubscription(); // Stop listening
              await FirebaseService.logoutUser();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, 'login'); // Move back to login screen upon logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Fully rounded button
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show dialog to add a new note
  Future<void> _showAddNoteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          minLines: 1,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final newNote = Note(
                  id: '',
                  text: text,
                  timestamp: Timestamp.fromDate(DateTime.now()),
                );


                await Provider.of<NoteProvider>(context, listen: false)
                    .addNote(newNote);

                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Note added successfully!', isSuccess: true);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  // Show dialog to edit an existing note
  Future<void> _showEditNoteDialog(BuildContext context, Note note) async {
    final controller = TextEditingController(text: note.text);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          minLines: 1,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Edit your note'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isNotEmpty && newText != note.text) {
                await Provider.of<NoteProvider>(context, listen: false)
                    .updateNote(note.id, newText);
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Note updated successfully!', isSuccess: true); // Feedback
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Ask for confirmation before deleting
  void _confirmDelete(BuildContext context, Note note) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false); // Capture here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.black),)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              final deletedNote = note; // Keep backup

              await noteProvider.deleteNote(note.id); // Use captured reference

              if (!mounted) return;

              // Show undo snackbar
              _showSnackBar(
                'Note deleted',
                isSuccess: true,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () async {
                    await noteProvider.restoreNote(deletedNote); // Use captured provider
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = Provider.of<NoteProvider>(context).notes;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back arrow
        centerTitle: true,
        title: const Text(
          'Your Notes',
          style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded menu shape
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Center(child: Text('Logout')),
                ),
              ],
            ),
          ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    kHintText, // From constants.dart
                    style: TextStyle(fontSize: 20),
                  ),
                )
                // Display as a ListView
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length, // However long the notes list is
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      // Display as a LisTile
                      child: ListTile(
                        title: Text(note.text),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditNoteDialog(context, note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, note),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Stack(
        children: [
          // FAB for Add Note (bottom-right)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.teal,
              heroTag: 'addNote',
              onPressed: () => _showAddNoteDialog(context),
              child: const Icon(Icons.add, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }
  // Cancel the Firestore notes listener when this screen is disposed.
  @override
  void dispose() {
    _noteProvider.cancelNoteSubscription();
    super.dispose();   // This prevents memory leaks and ensures the app doesn't keep listening after logout.
  }
}