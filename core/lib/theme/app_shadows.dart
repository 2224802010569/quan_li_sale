import 'package:flutter/material.dart';

/// Marine Precision Design System — Shadow / Elevation System
/// Source: update_UI.md § 1.4
abstract class AppShadows {
  /// Level 1 — Card
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0F0D3B7A), // rgba(13, 59, 122, 0.06)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 2 — Button / Input active
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1F0D3B7A), // rgba(13, 59, 122, 0.12)
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Level 3 — Modal / Picker / FAB
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x2E0D3B7A), // rgba(13, 59, 122, 0.18)
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}
