import 'package:flutter/material.dart';

/// Marine Precision Design System — Color Tokens
/// Source: update_UI.md § 1.2
abstract class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color surface                 = Color(0xFFF8F9FF);
  static const Color surfaceDim              = Color(0xFFCBDBF5);
  static const Color surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow     = Color(0xFFEFF4FF);
  static const Color surfaceContainer        = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh    = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color background              = Color(0xFFF8F9FF);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color onSurface              = Color(0xFF0B1C30);
  static const Color onSurfaceVariant       = Color(0xFF434750);
  static const Color inverseOnSurface       = Color(0xFFEAF1FF);

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary                = Color(0xFF002556);
  static const Color onPrimary              = Color(0xFFFFFFFF);
  static const Color primaryContainer       = Color(0xFF0D3B7A);
  static const Color onPrimaryContainer     = Color(0xFF84A7ED);
  static const Color inversePrimary         = Color(0xFFACC7FF);

  // ── Secondary / Action ───────────────────────────────────────────────────
  static const Color secondary              = Color(0xFF0051D5);
  static const Color onSecondary            = Color(0xFFFFFFFF);
  static const Color secondaryContainer     = Color(0xFF316BF3);
  static const Color onSecondaryContainer   = Color(0xFFFEFCFF);

  // ── Tertiary / Dark ──────────────────────────────────────────────────────
  static const Color tertiary               = Color(0xFF1A2837);
  static const Color tertiaryContainer      = Color(0xFF303E4E);
  static const Color onTertiaryContainer    = Color(0xFF9AA9BC);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error                  = Color(0xFFBA1A1A);
  static const Color onError                = Color(0xFFFFFFFF);
  static const Color errorContainer         = Color(0xFFFFDAD6);

  // ── Outline ──────────────────────────────────────────────────────────────
  static const Color outline                = Color(0xFF747781);
  static const Color outlineVariant         = Color(0xFFC3C6D2);
  static const Color surfaceTint            = Color(0xFF395D9E);
  static const Color surfaceVariant         = Color(0xFFD3E4FE);

  // ── Status Badge Colors ───────────────────────────────────────────────────
  static const Color statusActiveBg         = Color(0xFFDCFCE7);
  static const Color statusActiveText       = Color(0xFF16A34A);
  static const Color statusPendingBg        = Color(0xFFFFF7ED);
  static const Color statusPendingText      = Color(0xFFF97316);
  static const Color statusAssignedBg       = Color(0xFFEFF4FF);
  static const Color statusAssignedText     = Color(0xFF0051D5);
  static const Color statusRejectedBg       = Color(0xFFFEF2F2);
  static const Color statusRejectedText     = Color(0xFFBA1A1A);
  static const Color statusNewBg            = Color(0xFFE5EEFF);
  static const Color statusNewText          = Color(0xFF0051D5);

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const Color online                 = Color(0xFF4ADE80);
  static const Color white                  = Color(0xFFFFFFFF);
}
