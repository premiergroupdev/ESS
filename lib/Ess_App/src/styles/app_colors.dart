import 'package:flutter/material.dart';

/// Design tokens for the ESS app.
///
/// Every name from the previous AppColors is still here (accent, cardBg,
/// inputBg, error, warning, glassWhite, glassBorder, primaryGradient,
/// headerGradient, ...), so existing screens keep compiling. New tokens are
/// added for the revamped screens (app_widgets.dart).
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F3F64);
  static const Color primaryDark = Color(0xFF0A2C48);
  static const Color primaryLight = Color(0xFF1F5E8F);
  static const Color secondary = Color(0xFF5293C7);
  static const Color accent = Color(0xFF3A8FD6); // legacy

  /// Very light tint of the brand colour (selected rows, icon tiles, chips).
  static const Color primarySoft = Color(0xFFE8F0F7);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  /// `surface` is now WHITE (cards, dialogs, app-bar buttons), matching the
  /// new design. The page background is [background]. [cardBg] is a legacy
  /// alias kept so older files keep compiling.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F7FB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF5F8FB); // legacy
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // ── Text / neutrals ──────────────────────────────────────────────────────
  static const Color black = Color(0xFF0F172A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inkSoft = Color(0xFF475569);
  static const Color grey = Color(0xFF94A3B8); // hints, placeholders
  static const Color darkGrey = Color(0xFF64748B); // captions, secondary text
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFD9E2EC);
  static const Color divider = Color(0xFFE9EEF4);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE7F6EC);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3DC);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFDE8E8);
  static const Color error = danger; // legacy alias
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFE6EEFD);

  // ── Legacy accents (kept for existing screens) ───────────────────────────
  static const Color peach = Color(0xFFFCEFDA);
  static const Color yellow = Color(0xFFFFDB45);
  static const Color purple = Color(0xFFE3E4FD);
  static const Color green = Color(0xFF41BD6F);

  // ── Glassmorphism helpers (legacy) ───────────────────────────────────────
  static Color glassWhite = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.25);

  // ── Gradients / shadows ──────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  // legacy gradients, unchanged
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F3F64), Color(0xFF5293C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0A2D4A), Color(0xFF0F3F64), Color(0xFF1D5C8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primary.withOpacity(0.07),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get liftedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}