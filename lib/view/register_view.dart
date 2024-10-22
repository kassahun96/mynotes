import 'package:firebaseproject/services/auth/auth_expcetions.dart';
import 'package:firebaseproject/services/auth/auth_service.dart';
import 'package:firebaseproject/utilities/show_error_dialog.dart';
import 'package:firebaseproject/view/login_view.dart';
import 'package:firebaseproject/view/verify_email.dart';
import 'package:flutter/material.dart';

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
                              try {
                                final email = _email.text;
                                final password = _password.text;
                                await AuthService.firebase().createUser(
                                    email: email, password: password);

                                AuthService.firebase().sendEmailVerification();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const VerifyEmailView()));
                              } on WrongPasswordAuthException {
                                await showErrorDialog(context, 'Weak password');
                              } on EmailAlreadyInUseAuthExpcetion {
                                await showErrorDialog(
                                    context, 'Email already in use');
                              } on InvalidEmailAuthException {
                                await showErrorDialog(
                                    context, 'Please enter valid email');
                              } on GenericAuthExpcetion {
                                await showErrorDialog(
                                    context, 'Failed to register');
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
