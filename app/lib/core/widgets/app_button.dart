import 'package:flutter/material.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_shadows.dart';
import 'package:core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// Nút bấm chuẩn Marine Precision — 3 variants, tất cả height ≥ 44px
///
/// primary  → navy #002556, text trắng, shadow Level 2
/// secondary→ xanh #0051d5, text trắng, shadow Level 2
/// ghost    → transparent border, text secondary
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final double? borderRadius;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.icon,
    this.width,
    this.height = AppSpacing.touchTarget,
    this.borderRadius,
    this.isLoading = false,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = AppSpacing.touchTarget,
    this.borderRadius,
    this.isLoading = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = AppSpacing.touchTarget,
    this.borderRadius,
    this.isLoading = false,
  }) : variant = AppButtonVariant.ghost;

  Color get _bg {
    switch (variant) {
      case AppButtonVariant.primary:   return AppColors.primary;
      case AppButtonVariant.secondary: return AppColors.secondary;
      case AppButtonVariant.ghost:     return Colors.transparent;
    }
  }

  Color get _fg {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary: return AppColors.white;
      case AppButtonVariant.ghost:     return AppColors.secondary;
    }
  }

  List<BoxShadow>? get _shadow {
    if (variant == AppButtonVariant.ghost) return null;
    return AppShadows.level2;
  }

  BorderSide get _border {
    if (variant == AppButtonVariant.ghost) {
      return const BorderSide(color: AppColors.secondary, width: 1.5);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;
    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.labelLg.copyWith(color: _fg),
              ),
            ],
          );

    return GestureDetector(
      onTap: onPressed == null ? null : () => onPressed!(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: onPressed == null ? _bg.withOpacity(0.4) : _bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.fromBorderSide(_border),
          boxShadow: onPressed == null ? null : _shadow,
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
