import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Ess_App/src/styles/app_colors.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startTimer();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hours = now.hour % 12;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return "${_twoDigits(hours)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)} $ampm";
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          _currentTime,
            style: GoogleFonts.poppins(
              color: AppColors.white,
fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
        ),
      ),
    );
  }
}
