import 'package:firebaseproject/services/auth/auth_expcetions.dart';
import 'package:firebaseproject/services/auth/auth_provider.dart';
import 'package:firebaseproject/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock authentication', () {
    final provider = MockeAuthProvider();
    test('Should not initialized when it starts', () {
      expect(provider.isInitialized, false);
    });

    test('Not log out if not initialized ', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitiaizedException>()));
    });

    test('should be able to be intiliazed', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('a user should be null after initialized', () {
      expect(provider._user, null);
    });

    test('should be able to initialize less than 2 second', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user account should delegate to login user', () async {
      final invalidEmail =
           provider.createUser(email: 'foo@bar.com', password: 'pass');
      expect(invalidEmail,   throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword =  provider.createUser(
          email: 'someone@gmail.com', password: 'foobar');
      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = provider.currentUser;

      expect(provider.currentUser, user);
      expect(user?.isEmailVerified, false);
    });

    test('login user should be verified', () async{
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);

      expect(user!.isEmailVerified, false);
    });

    test('should be abe to log in and log out', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitiaizedException implements Exception {}

class MockeAuthProvider implements CustomAuthProvider {
  AuthUser? _user;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required password}) async {
    if (!_isInitialized) throw NotInitiaizedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required password}) {
    if (!_isInitialized) throw NotInitiaizedException();
    //checking the email and the password
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    //checking verification
    const user = AuthUser(isEmailVerified: false, email: '');
    _user = user;
    //return the user as the future
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitiaizedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async { 
    if (!_isInitialized) throw NotInitiaizedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(isEmailVerified: true, email: user.email);
    _user = newUser;
  }
}
