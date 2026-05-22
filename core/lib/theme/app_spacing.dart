/// Marine Precision Design System — Spacing & Radius Tokens
/// Source: update_UI.md § 1.3
abstract class AppSpacing {
  // ── Layout ────────────────────────────────────────────────────────────────
  static const double containerMargin = 16.0; // margin hai bên màn hình
  static const double stackGap        = 12.0; // khoảng cách giữa các block
  static const double cardPadding     = 20.0; // padding bên trong card
  static const double gridGutter      = 16.0; // gutter giữa các cột
  static const double touchTarget     = 44.0; // chiều cao tối thiểu button/row

  // ── Radius ───────────────────────────────────────────────────────────────
  static const double radiusSm   = 4.0;    // input tag nhỏ
  static const double radius     = 8.0;    // input, tag, button nhỏ
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;   // card
  static const double radiusXl   = 24.0;   // bottom sheet, modal
  static const double radiusFull = 9999.0; // pill

  // ── Common Paddings (shortcuts) ───────────────────────────────────────────
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
}
