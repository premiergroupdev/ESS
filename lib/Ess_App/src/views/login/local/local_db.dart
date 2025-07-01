import 'package:ess/Ess_App/src/views/notification/Notification_provider.dart';
import 'package:ess/Ess_App/src/views/notification/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../models/api_response_models/Notification.dart';
import '../../local_db.dart';

class DatabaseHelpe with ChangeNotifier{
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
        await db.execute(
            'CREATE TABLE notification_counts('
                'id INTEGER PRIMARY KEY,'
                'notifications_count INTEGER DEFAULT 0'
                ')');
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
      await insertNotificationCount(1);
      await getNotificationCount();
      // // Delay execution until widget tree is built
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   loadUnreadCount(); // Now navigatorKey.currentContext will be available
      // });

      print("Inserted data successfully");
    } catch (e) {
      print("Failed to insert data: $e");
      throw Exception("Failed to insert notification into database");
    }
  }

  Future<void> loadUnreadCount({int retryCount = 5}) async {
    final db = await DatabaseHelpe().database;
    final list = await db.query('notification');
    NotiCount.count.value= list.length;
  //  final ctx = navigatorKey.currentContext;

    // if (ctx != null) {
    //   ctx.read<NotificationProvider>().setCount(list.length);
    //   print("🔔 Updated count: ${ctx.read<NotificationProvider>().count}");
    // } else if (retryCount > 0) {
    //   print("Context not ready, retrying... ($retryCount)");
    //   await Future.delayed(Duration(milliseconds: 300));
    //   loadUnreadCount(retryCount: retryCount - 1);
    // } else {
    //   print("❌ Failed to get context after retries.");
    // }
  }



  Future<void> markAllAsRead() async {
    final Database db = await DatabaseHelpe().database;
    await db.update('notification', {'notifications_count': 1});
    NotiCount.count.value = 0;
    notifyListeners();
  }
  Future<void> getNotificationCount() async {
    final Database db = await database;
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM notification_counts')) ?? 0;
    NotiCount.count.value= count;
    print("Get count${NotiCount.count.value}");
    notifyListeners();


  }
  Future<void> updateNotificationCount() async {
    final Database db = await database;
    NotiCount.count.value = 0;
    NotificationListener;
    print("hey");
    await db.delete('notification_counts');
  }
  Future<void> insertNotificationCount(int count) async {
    final Database db = await database;

    await db.insert(
      'notification_counts',
      {'notifications_count': count},

      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("insert");
  }

  // Future<void> loadNotificationCounts() async {
  //   try {
  //     int count = await getNotificationCount();
  //     NotiCount.count.value= count;
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error loading notification count: $e');
  //
  //   }
  // }


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


  // Future<int> getNotificationCount() async {
  //   final Database db = await database;
  //   int count = Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(*) FROM notification_counts')) ?? 0;
  //   return count;
  // }
  //
  // Future<void> updateNotificationCount() async {
  //   final Database db = await database;
  //   await db.delete('notification_counts');
  // }
  // Future<void> insertNotificationCount(int count) async {
  //   final Database db = await database;
  //   await db.insert(
  //     'notification_counts',
  //     {'notifications_count': count},
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }










}
