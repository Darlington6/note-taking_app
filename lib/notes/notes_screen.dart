// import packages/modules
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  // Shows styled SnackBar (floating top-right, green/red)
  void _showSnackBar(String message, {bool isSuccess = false, SnackBarAction? action}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: action,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              final deletedNote = note; // Keep backup

              await Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id);

              if (!mounted) return;

              // Show undo snackbar
              _showSnackBar(
                'Note deleted',
                isSuccess: true,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () async {
                    await Provider.of<NoteProvider>(context, listen: false).restoreNote(deletedNote);
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
        iconTheme: IconThemeData(
          color: Colors.white, // Set back arrow color to white for enhanced visibility
        ),
        centerTitle: true,
        title: const Text(
          'Your Notes',
          style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    'Nothing here yet—tap ➕ to add a note.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}