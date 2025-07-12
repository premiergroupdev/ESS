import 'package:flutter/material.dart';

extension UIExt on BuildContext {
  double topSpace() => MediaQuery.of(this).padding.top;

  double appBarHeight() => AppBar().preferredSize.height;

  Size screenSize() => MediaQuery.of(this).size;


  void closeKeyboardIfOpen() {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
  }
}
