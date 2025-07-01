// import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../login/local/local_db.dart';
//
// class NotificationProvider with ChangeNotifier {
//   int _unreadCount = 0;
//
//   int get unreadCount => _unreadCount;
//
//   // Future<void> loadUnreadCount() async {
//   //   final Database db = await DatabaseHelpe().database;
//   //   final List<Map<String, dynamic>> list = await db.query(
//   //     'notification',
//   //   );
//   //   _unreadCount = list.length;
//   //   notifyListeners();
//   //   print("Unread: ${_unreadCount}");
//   // }
//   //
//   // Future<void> markAllAsRead() async {
//   //   final Database db = await DatabaseHelpe().database;
//   //   await db.update('notification', {'notifications_count': 1});
//   //   _unreadCount = 0;
//   //   notifyListeners();
//   // }
// }
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void setCount(int count) {
    _count = count;
    print("abc: ${count}");
    notifyListeners(); // Notifies widgets listening to this provider
  }

  void clear() {
    _count = 0;
    notifyListeners();
  }
}
