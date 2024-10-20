// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseproject/view/login_view.dart';
import 'package:firebaseproject/view/note_view.dart';
import 'package:firebaseproject/view/verify_email.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase before running the app
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String verfied = 'not yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  if (currentUser?.emailVerified ?? false) {
                    return NoteView();
                  } else {
                    return LoginView();
                  }
                } else {
                  return LoginView();
                }

              default:
                return const Text('loading');
            }
          }),
    );
  }
}
