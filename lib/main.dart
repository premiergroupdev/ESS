import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ess/Ess_App/src/services/local/auth_service.dart';
import 'package:ess/Ess_App/src/services/remote/api_service.dart';
import 'package:ess/Ess_App/src/views/dashboard/dashboard_view_model.dart';
import 'package:ess/Ess_App/src/views/local_db.dart';
import 'package:ess/Ess_App/src/views/notification/Notification_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ess/Ess_App/src/app/app_view.dart';
import 'package:ess/Ess_App/src/configs/app_setup.locator.dart';
import 'package:ess/Ess_App/src/services/local/flavor_service.dart';

import 'Ess_App/src/services/remote/app_update_wrapper.dart';
import 'Ess_App/src/views/PDMS_survey/product_search_provider.dart';
import 'Ess_App/src/views/login/local/local_db.dart';

DateTime? lastApiCallTime;

DatabaseHelper database = DatabaseHelper();
DatabaseHelpe DBHelper = DatabaseHelpe();

ApiService api = ApiService();
DashboardViewModel dashboard = DashboardViewModel();

/// ============================
/// DEVICE INFO
/// ============================
Future<void> checkApiLevel() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('📱 Android: ${androidInfo.brand} ${androidInfo.model}');
      print('🎯 API Level: ${androidInfo.version.sdkInt}');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('📱 iOS: ${iosInfo.systemVersion}');
    }
  } catch (e) {
    print('Device info error: $e');
  }
}

/// ============================
/// MAIN
/// ============================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await checkApiLevel();
  await DBHelper.getNotificationCount();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('isDialogShown');

  AuthService.prefs = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final package = await PackageInfo.fromPlatform();
  setupLocator();
  FlavorService.init(package);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: MaterialApp(                   // ✅ MaterialApp at the top
        debugShowCheckedModeBanner: false,
        home: AppUpdateWrapper(             // ✅ wrapper is home, inside MaterialApp
          checkInterval: Duration(seconds: 10),
          child: AppView(),
        ),
      ),
    ),
  );
}