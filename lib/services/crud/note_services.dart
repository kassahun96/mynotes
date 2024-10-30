// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'crud_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String idColumn = 'id';
const String emailColumn = 'email';

class NoteService {
  List<DatabaseNote> _notes = [];
  //create an instance of the class inside the class then use it throught the 
  NoteService._sharedInstance();
  static final NoteService instance = NoteService._sharedInstance();
  final _noteStreamController =
      StreamController<List<DatabaseNote>>.broadcast();
  Stream<List<DatabaseNote>> get allNotes => _noteStreamController.stream;
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  Database? _db;
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindTheUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

//Database

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpened();
    } else {
      return db;
    }
  }

  Future<void> _ensureDatabaseOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {}
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenedException();
    try {
      final filePath = await getApplicationDocumentsDirectory();
      final dbPath = join(filePath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNoteTable);
      _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpened();
    } else {
      await db.close();
      _db = null;
    }
  }


//Note crud
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount =
        await db.update(noteTable, {textColumn: text, isSynchedWithCloud: 0});

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _noteStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindTheNote();
    } else {
      return DatabaseNote.fromRow(results.first);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _noteStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    //make sure the database exists
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindTheUser();
    }

    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSynchedWithCloud: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedToCloud: false,
    );
    _notes.add(note);
    _noteStreamController.add(_notes);
    return note;
  }


///User crud
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindTheUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();
    final results =
        await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [
      email.toLowerCase(),
    ]);
    if (results.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId = await db.insert(userTable, {emailColumn: email});
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabaseOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID: $id, Email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedToCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedToCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        text = map[emailColumn] as String,
        userId = map[userIdColumn] as int,
        isSyncedToCloud = (map[isSynchedWithCloud]) as int == 1 ? true : false;

  @override
  String toString() =>
      "Note , ID $id, UserId: $userId , isSychedWithCoud: $isSyncedToCloud";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const userTable = 'user';
const noteTable = 'note';
const textColumn = 'text';
const userIdColumn = 'user_id';
const isSynchedWithCloud = 'is_synched_with_cloud';
const dbName = 'notes.db';
//create user table

const createUserTable = '''
    CREATE TABLE "User" (
	  "id"	INTEGER NOT NULL,
	  "email"	TEXT NOT NULL UNIQUE,
	  PRIMARY KEY("id" AUTOINCREMENT)
    );
  ''';

//create not table

const createNoteTable = ''' CREATE TABLE  IF NOT EXIST "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"is_synched_with_cloud"	INTEGER DEFAULT 0,
	PRIMARY KEY("id"),
	FOREIGN KEY("user_id") REFERENCES "User"("id")
);

''';
