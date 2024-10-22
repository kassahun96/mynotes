// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebaseproject/services/auth/auth_provider.dart';
import 'package:firebaseproject/services/auth/auth_user.dart';
import 'package:firebaseproject/services/auth/firebase_auth_provider.dart';

class AuthService implements CustomAuthProvider {
final CustomAuthProvider authProvider;

const AuthService({
    required this.authProvider,
  });


  factory AuthService.firebase() =>
      AuthService(authProvider: FirebaseAuthProvider());


  @override
  Future<AuthUser> createUser({required String email, required password}) =>
      authProvider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required password}) =>
      authProvider.logIn(email: email, password: password);
  @override
  Future<void> logOut() => authProvider.logOut();

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();

  @override
  Future<void> initialize() => authProvider.initialize();
}
