import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../models/api_response_models/Notification.dart';

class DatabaseHelpe {
  static final DatabaseHelpe _instance = DatabaseHelpe._internal();
  factory DatabaseHelpe() => _instance;
  DatabaseHelpe._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Future<Database> _initDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'user_credentials.db');
  //
  //   return await openDatabase(
  //     path,
  //     version: 1,
  //     onCreate: (db, version) {
  //       return db.execute(
  //         "CREATE TABLE user_credentials(id INTEGER PRIMARY KEY, email TEXT, password TEXT)",
  //       );
  //
  //       return db.execute(
  //         'CREATE TABLE notification('
  //             'Id INTEGER PRIMARY KEY,'
  //             'title TEXT,'
  //             'body TEXT,'
  //             'timestamp TEXT'
  //             ')',
  //       );
  //     },
  //   );
  // }
  //


  // Future<Database> initDatabase() async {
  //   return openDatabase(
  //     join(await getDatabasesPath(), 'user_credentials.db'),
  //     onCreate: (db, version) async {
  //       db.execute('CREATE TABLE user_credentials(id INTEGER PRIMARY KEY, email TEXT, password TEXT)',);
  //       return db.execute(
  //           'CREATE TABLE notification('
  //               'Id INTEGER PRIMARY KEY,'
  //               'title TEXT,'
  //               'body TEXT,'
  //               'timestamp TEXT'
  //               ')');
  //
  //     },
  //     version: 1,
  //   );
  // }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'user_credential.db'),
      onCreate: (db, version) async {
        db.execute('CREATE TABLE user_credentials(id INTEGER PRIMARY KEY, email TEXT, password TEXT)',);

        db.execute('CREATE TABLE notification('
              'Id INTEGER PRIMARY KEY,'
              'title TEXT,'
              'body TEXT,'
              'timestamp TEXT,'
              'notifications_count'
              ')',
        );
      },
      version: 1,
    );
  }
  Future<void> insertUser(String email, String password) async {
    final db = await database;
    await db.insert(
      'user_credentials',
      {
        'email': email,
        'password': password
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser( ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_credentials');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }


  Future<bool> checkTable() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('user_credentials', limit: 1,);
    return result.isNotEmpty;
  }

  Future<void> updateUser(String email, String password) async {
    final db = await database;
    await db.update('user_credentials', {'email': email, 'password': password },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user_credentials');
  }


  Future<void> insertnotification(Notification_model model) async {
    try {
      final Database db = await database;

      await db.insert('notification', model.toJson());
      print("Inserted data successfully");
    } catch (e) {
      print("Failed to insert data: $e");
      throw Exception("Failed to insert notification into database");
    }
  }


  Future<List<Notification_model>> getnotification() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> list = await db.query('notification');

      List<Notification_model> model = list.map((e) => Notification_model.fromJson(e)).toList();

      return model;
    } catch (e) {
      print("Failed to retrieve notifications: $e");
      throw Exception("Failed to retrieve notifications from database");
    }
  }















}
