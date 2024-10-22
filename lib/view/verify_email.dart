import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}



class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text('Verify Email'),
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("We've sent you an email verification. Please open it to verify your account."),
          const Text("If you haven't recieved a verification email yet, press the button below"),
          TextButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                await currentUser?.sendEmailVerification();
              },
              child: const Text('Send email verification')),
        ],
      ),
    );
  }
}

