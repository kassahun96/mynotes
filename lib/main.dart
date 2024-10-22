// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:firebaseproject/services/auth/auth_service.dart';
import 'package:firebaseproject/view/login_view.dart';
import 'package:firebaseproject/view/note_view.dart';
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String verfied = 'not yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final currentUser = AuthService.firebase().currentUser;
                if (currentUser != null) {
                  if (currentUser.isEmailVerified) {
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
