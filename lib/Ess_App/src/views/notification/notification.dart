import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../models/api_response_models/Notification.dart';
import '../local_db.dart';
import '../login/local/local_db.dart';

DatabaseHelpe _databaseHelper = DatabaseHelpe();
@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  try {
    print("Handling a background message: ${message.messageId}");

    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');

      Notification_model notification = Notification_model(
        title: message.notification!.title,
        body: message.notification!.body,
        timestamp: message.sentTime ?? DateTime.now(), // Use sentTime or current time
      );

      // Access your database helper instance
      await _databaseHelper.insertnotification(notification);
    }

    print('Payload data: ${message.data}');
  } catch (e) {
    print('Error handling background message: $e');
    // Handle the exception as needed, such as logging it or reporting it.
  }
}


class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification({BuildContext? context}) async {
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS (optional but recommended)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Firebase messaging setup
    await _firebaseMessaging.requestPermission();

    await _firebaseMessaging.subscribeToTopic('general');
    print("Subscribed to topic 'general'");

    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received a message in the foreground: ${message.messageId}');

      if (message.notification != null) {
        showLocalNotification(message.notification!);

        DateTime currentTime = DateTime.now();
        Notification_model notification = Notification_model(
          title: message.notification!.title,
          body: message.notification!.body,
          timestamp: message.sentTime ?? currentTime,
        );

        await _databaseHelper.insertnotification(notification);
      }

      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      if (message.notification != null && context != null) {
        print('Title: ${message.notification!.title}');
        print('Body: ${message.notification!.body}');
      }
      print('Data: ${message.data}');
    });
  }

  void showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'default_channel_id', // id
      'Default', // title
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}