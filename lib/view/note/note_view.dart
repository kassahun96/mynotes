import 'package:firebaseproject/view/note/new_note_view.dart';

import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/crud/note_services.dart';
import '../login_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  String? get userEmail => AuthService.firebase().currentUser?.email;
  @override
  void initState() {
    NoteService.instance.open();
    super.initState();
  }

  @override
  void deactivate() {
    NoteService.instance.close();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Note view'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NewNoteView();
                }));
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            final shouldLogout = await showLogoutDialog(context);
            devtools.log(shouldLogout.toString());
            if (shouldLogout) {
              AuthService.firebase().logOut();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const LoginView();
              }));
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text('Log out'))
            ];
          })
        ],
      ),
      body: FutureBuilder(
          future: NoteService.instance.getOrCreateUser(email: userEmail!),
          builder: (context, snapShot) {
            switch (snapShot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: NoteService.instance.allNotes,
                    builder: (context, snapShot) {
                      switch (snapShot.connectionState) {
                        case ConnectionState.waiting:
                          return const Text('Waiting for all notes......');
                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                const Center(
                  child: CircularProgressIndicator(),
                );
                return const Text('Hello World');
            }
          }),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure to log out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Logout')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
          ],
        );
      }).then((value) => value ?? false);
}