import 'package:firebaseproject/services/auth/auth_user.dart';
//this abstract the FirebaseAuth
abstract class CustomAuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({required String email, required dynamic password});

  Future<AuthUser> createUser(
      {required String email, required dynamic password});

  Future<void> logOut();

  Future<void> sendEmailVerification();

}
