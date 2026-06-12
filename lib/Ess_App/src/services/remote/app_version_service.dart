import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

class AppVersionService {
  static const _versionUrl =
      "https://premierspulse.com/ess/scripts/fetch_live_version.php";

  static Future<bool> isUpToDate() async {
    try {
      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return true;

      final data = jsonDecode(response.body);

      final serverAndroid = _parseVersion(data['android_version']);
      final serverIos = _parseVersion(data['ios_version']);
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = _parseVersion(packageInfo.version);

      debugPrint(
          '🔢 Local: $localVersion | Server Android: $serverAndroid | iOS: $serverIos');

      if (Platform.isAndroid) return localVersion >= serverAndroid;
      if (Platform.isIOS) return localVersion >= serverIos;

      return true;
    } catch (e) {
      debugPrint('⚠️ Version check failed: $e');
      return true;
    }
  }

  static int _parseVersion(dynamic value) {
    return int.tryParse(value?.toString().trim().split('.').first ?? '0') ?? 0;
  }
}