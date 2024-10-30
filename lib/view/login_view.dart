import '../services/auth/auth_expcetions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart';
import 'note/note_view.dart';
import 'register_view.dart';
import 'verify_email.dart';
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
              future: AuthService.firebase().initialize(),
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
                                await AuthService.firebase()
                                    .logIn(email: email, password: password);
                                final user = AuthService.firebase().currentUser;
                                if (user?.isEmailVerified ?? false) {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const NoteView();
                                  }));
                                } else {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const VerifyEmailView();
                                  }));
                                }
                              } on UserNotFoundAuthException {
                                await showErrorDialog(
                                    context, 'User not found');
                              } on WrongPasswordAuthException {
                                await showErrorDialog(
                                    context, 'Wrong credential');
                              } on GenericAuthExpcetion {
                                await showErrorDialog(
                                    context, 'Authentication Error');
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
                      return const RegisterView();
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
