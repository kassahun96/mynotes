import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseproject/services/auth/auth_expcetions.dart';
import 'package:firebaseproject/services/auth/auth_provider.dart';
import 'package:firebaseproject/services/auth/auth_user.dart';

class FirebaseAuthProvider implements CustomAuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLogInAuthExpcetion();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthExpcetion();
      } else if (e.code == "email-already-in-use") {
        throw EmailAlreadyInUseAuthExpcetion();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthExpcetion();
      }
    } catch (e) {
      throw GenericAuthExpcetion();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLogInAuthExpcetion();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user_not_found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthExpcetion();
      }
    } catch (_) {
      throw GenericAuthExpcetion();
    }
  }

  @override
  Future<void> logOut() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLogInAuthExpcetion();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.sendEmailVerification();
    } else {
      throw UserNotLogInAuthExpcetion();
    }
  }
}
