//Login expcetions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}


//register expcetions

class WeakPasswordAuthExpcetion implements Exception{}

class EmailAlreadyInUseAuthExpcetion implements Exception{}

class InvalidEmailAuthException implements Exception{}

//Generic expcetions

class GenericAuthExpcetion implements Exception{}

class UserNotLogInAuthExpcetion implements Exception{}