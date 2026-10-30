import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// All previous style names are preserved (same sizes) so no screen shifts
/// layout. New semantic styles are added at the bottom for new/revamped UI.
class TextStyling {
  TextStyling._();

  static TextStyle _inter(double size, FontWeight weight, {double? height}) =>
      GoogleFonts.inter(
        fontSize: size,
        color: AppColors.black,
        fontWeight: weight,
        height: height,
      );

  // ── Existing names ───────────────────────────────────────────────────────
  static TextStyle extraBold24 = _inter(24, FontWeight.w800);
  static TextStyle extraBold22 = _inter(22, FontWeight.w800);

  static TextStyle bold22 = _inter(22, FontWeight.w700);
  static TextStyle bold20 = _inter(20, FontWeight.w700);
  static TextStyle bold18 = _inter(18, FontWeight.w700);
  static TextStyle bold16 = _inter(16, FontWeight.w600);
  static TextStyle bold14 = _inter(14, FontWeight.w600);

  static TextStyle text18 = _inter(18, FontWeight.w500);
  static TextStyle text16 = _inter(16, FontWeight.w500);
  static TextStyle text14 = _inter(14, FontWeight.w500);
  static TextStyle text15 = _inter(14, FontWeight.w500);
  static TextStyle text12 = _inter(10, FontWeight.w500);

  static TextStyle paragraph14 = _inter(14, FontWeight.w400, height: 1.45);
  static TextStyle paragraph12 = _inter(12, FontWeight.w400, height: 1.45);
  static TextStyle paragraph10 = _inter(10, FontWeight.w400, height: 1.4);

  // ── New semantic styles ──────────────────────────────────────────────────
  static TextStyle display = _inter(28, FontWeight.w800, height: 1.15);
  static TextStyle title = _inter(18, FontWeight.w700, height: 1.25);
  static TextStyle section = _inter(16, FontWeight.w700);
  static TextStyle body = _inter(14, FontWeight.w400, height: 1.45)
      .copyWith(color: AppColors.inkSoft);
  static TextStyle label = _inter(13, FontWeight.w600)
      .copyWith(color: AppColors.inkSoft);
  static TextStyle caption = _inter(12, FontWeight.w500)
      .copyWith(color: AppColors.darkGrey);
  static TextStyle button = _inter(16, FontWeight.w600)
      .copyWith(color: AppColors.white);
}
