// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';

import 'services/auth/auth_service.dart';
import 'view/login_view.dart';
import 'view/note/note_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService.firebase().initialize();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NoteView(),
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
