import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();


  static Future<void> initialize() async {
    // Define initialization settings for Android and iOS
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/premierlogo'),
      iOS:

      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    try {
      // Initialize the notifications plugin
      bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        // onSelectNotification: (String? payload) async {
        //   // Handle notification selection (notification click)
        //   print('Notification clicked with payload: $payload');
        //   // You can navigate or show the notification content here
        // },
      );

      // Checking initialization success
      if (initialized ?? false) {
        print("LocalNotificationService initialized successfully.");
      } else {
        print("LocalNotificationService failed to initialize.");
      }
    } catch (e) {
      print("Error initializing LocalNotificationService: $e");
    }
  }

  static void createAndDisplayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "premierEss",
          "premierEssChannel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}