import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_version_service.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';

class AppUpdateWrapper extends StatefulWidget {
  final Widget child;
  final Duration checkInterval;

  const AppUpdateWrapper({
    super.key,
    required this.child,
    this.checkInterval = const Duration(minutes: 30),
  });

  @override
  State<AppUpdateWrapper> createState() => _AppUpdateWrapperState();
}

class _AppUpdateWrapperState extends State<AppUpdateWrapper>
    with WidgetsBindingObserver {
  bool _isUpToDate = true;
  bool _loading = true;
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runVersionCheck();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runVersionCheck();
    }
  }

  void _startPeriodicCheck() {
    _periodicTimer = Timer.periodic(widget.checkInterval, (_) {
      _runVersionCheck();
    });
  }

  Future<void> _runVersionCheck() async {
    final upToDate = await AppVersionService.isUpToDate();
    if (!mounted) return;
    if (upToDate != _isUpToDate || _loading) {
      setState(() {
        _isUpToDate = upToDate;
        _loading = false;
      });
    }
  }

  Future<void> _openStore() async {
    final url = Platform.isAndroid
        ? "https://play.google.com/store/apps/details?id=com.premiergroup.ess"
        : "https://apps.apple.com/app/id6746352124";

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isUpToDate) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.system_update, size: 90, color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    "Update Required",

                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "A new version of the app is available.\n"
                        "Please update to continue using ESS.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15,color: AppColors.primary),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _openStore,
                    icon: Icon(Icons.download, color: Colors.white),
                    label: Text("Update Now", style: TextStyle(color: AppColors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}