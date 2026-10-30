import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:flutter/material.dart';

/// Same API as before; default colour is now the brand navy instead of black.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final double? value;

  const LoadingIndicator({
    Key? key,
    this.size = 30,
    this.strokeWidth = 3,
    this.color = AppColors.primary,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
