import 'package:flutter/material.dart';

/// Marine Precision Design System — Typography Tokens
/// Source: update_UI.md § 1.1
/// Font: Be Vietnam Pro (apply via google_fonts in app package)
///
/// Usage:
///   Text('Hello', style: AppTextStyles.headlineLg)
abstract class AppTextStyles {
  // Sử dụng fontFamily 'BeVietnamPro' — được set bởi ThemeData.fontFamily
  // Khi ThemeData đã set fontFamily, tất cả TextStyle sẽ tự động dùng font đó.

  /// headline-lg: 24px / 700 / lh 32 / ls -0.02em
  static const TextStyle headlineLg = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.48, // -0.02em × 24px
    fontFamily: 'BeVietnamPro',
  );

  /// headline-md: 20px / 600 / lh 28
  static const TextStyle headlineMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    fontFamily: 'BeVietnamPro',
  );

  /// headline-sm: 18px / 600 / lh 24
  static const TextStyle headlineSm = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    fontFamily: 'BeVietnamPro',
  );

  /// body-lg: 16px / 400 / lh 24
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    fontFamily: 'BeVietnamPro',
  );

  /// body-md: 14px / 400 / lh 20
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    fontFamily: 'BeVietnamPro',
  );

  /// label-lg: 14px / 600 / lh 20 / ls 0.05em
  static const TextStyle labelLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.7, // 0.05em × 14px
    fontFamily: 'BeVietnamPro',
  );

  /// label-md: 12px / 500 / lh 16
  static const TextStyle labelMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    fontFamily: 'BeVietnamPro',
  );

  /// caption: 11px / 400 / lh 14
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 14 / 11,
    fontFamily: 'BeVietnamPro',
  );
}
