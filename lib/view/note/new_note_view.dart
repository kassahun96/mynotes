import 'package:firebaseproject/services/auth/auth_service.dart';
import 'package:firebaseproject/services/crud/note_services.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;

  final _textEditingController = TextEditingController();

  Future<DatabaseNote> createNewNote() async {
    final exisitingNote = _note;
    if (exisitingNote != null) {
      return exisitingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await NoteService.instance.getUser(email: email);
    return await NoteService.instance.createNote(owner: owner);
  }

  void _textControllerListner() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;
    await NoteService.instance.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListner);
    _textEditingController.addListener(_textControllerListner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      NoteService.instance.deleteNote(id: note!.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await NoteService.instance.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _saveNoteIfTextNotEmpty();
    _deleteNoteIfTextIsEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null, 
                decoration: const InputDecoration(
                  hintText: 'Start typing your note.....'
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
