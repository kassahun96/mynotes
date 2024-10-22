import 'package:firebaseproject/utilities/show_error_dialog.dart';
import 'package:firebaseproject/view/login_view.dart';
import 'package:firebaseproject/view/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
                              try {
                                final email = _email.text;
                                final password = _password.text;
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: email, password: password);
                                final user = FirebaseAuth.instance.currentUser;
                                user?.sendEmailVerification();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const VerifyEmailView()));
                              } on FirebaseAuthException catch (e) {
                                showErrorDialog(context, e.code);
                              } catch (e) {
                                showErrorDialog(context, e.toString());
                              }
                            },
                            child: const Text('Register'))
                      ],
                    );
                  default:
                    return const Text('loading');
                }
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already register?'),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const LoginView();
                    }));
                  },
                  child: const Text('Login here'))
            ],
          )
        ],
      ),
    );
  }
}
