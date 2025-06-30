// import packages/modules
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/note_provider.dart';
import '../../data/models/note.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  // Shows a dialog to enter a new note and adds it to the list
  Future<void> _showAddNoteDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final noteText = controller.text.trim();
              if (noteText.isNotEmpty) {
                final newNote = Note(
                  id: DateTime.now().toString(), // Temp ID, will be replaced
                  text: noteText,
                );
                Provider.of<NoteProvider>(context, listen: false).addNote(newNote);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
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
        title: const Text('Your Notes'),
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'Nothing here yet—tap ➕ to add a note.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(note.text),
                    // Actions like edit/delete will come later
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