import 'package:ess/Ess_App/src/base/utils/utils.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:flutter/material.dart';

BorderRadius _resolveRadius(BorderRadiusGeometry? value, double fallback) {
  if (value is BorderRadius) return value;
  return BorderRadius.circular(fallback);
}

/// Primary call-to-action. Signature unchanged.
///
/// Tap behaviour is kept as before (a disabled-but-idle button still fires
/// [onTap], because some screens rely on that to show validation toasts). The
/// only change: taps are ignored while [isBusy], which prevents double submits.
class MainButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final Widget? icon;
  final Function onTap;
  final bool isEnabled;
  final bool isBusy;
  final BorderRadiusGeometry? borderRadius;

  const MainButton(
      {Key? key,
        required this.text,
        this.width,
        this.height,
        this.icon,
        required this.onTap,
        this.isEnabled = true,
        this.borderRadius,
        this.isBusy = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = _resolveRadius(borderRadius, 14);

    return SizedBox(
      width: width ?? context.screenSize().width,
      height: height ?? 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: isEnabled
              ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          )
              : null,
          color: isEnabled ? null : AppColors.primary.withOpacity(0.35),
          boxShadow: isEnabled ? AppColors.softShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              if (isBusy) return;
              onTap();
            },
            child: Center(
              child: isBusy
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.white,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.button,
                    ),
                  ),
                  if (icon != null) const SizedBox(width: 8),
                  if (icon != null) icon!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action. Signature unchanged.
class SecondaryButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final Widget? icon;
  final Function onTap;
  final Color? color;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.width,
    this.height,
    this.icon,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: width ?? context.screenSize().width,
      height: height ?? 52,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: color ?? AppColors.border,
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => onTap(),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyling.button.copyWith(color: tint),
                  ),
                ),
                if (icon != null) const SizedBox(width: 8),
                if (icon != null) icon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round image button. Signature unchanged.
class RoundIconButton extends StatelessWidget {
  final String icon;
  final Function onTap;

  const RoundIconButton({Key? key, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: AppColors.primary.withOpacity(0.35),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTap(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Image.asset(icon, height: 24, width: 24),
          ),
        ),
      ),
    );
  }
}