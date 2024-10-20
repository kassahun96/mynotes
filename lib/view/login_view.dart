import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseproject/view/note_view.dart';
import 'package:firebaseproject/view/register_view.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Column(
                      children: [
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'Email'),
                        ),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration:
                              const InputDecoration(hintText: 'password'),
                        ),
                        TextButton(
                            onPressed: () async {
                              final email = _email.text;
                              final password = _password.text;
                              try {
                                final userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                        email: email, password: password);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return NoteView();
                                }));
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'invalid-credential') {
                                  print('kassahun user is not found');
                                }
                                print('kassahun other problem ${e.code}');
                              }
                            },
                            child: const Text('Login'))
                      ],
                    );
                  default:
                    return const Text('loading');
                }
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not register yet?'),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return RegisterView();
                    }));
                  },
                  child: const Text('Regster here'))
            ],
          )
        ],
      ),
    );
  }
}
