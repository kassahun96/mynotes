
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseproject/view/login_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;


enum MenuAction { logout }
class NoteView extends StatelessWidget {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Note view'),
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            final shouldLogout = await showLogoutDialog(context);
            devtools.log(shouldLogout.toString());

            if (shouldLogout) {
              FirebaseAuth.instance.signOut();
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