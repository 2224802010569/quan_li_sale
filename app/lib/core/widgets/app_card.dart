import 'package:flutter/material.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_shadows.dart';

/// White card với Level 1 shadow — dùng bao bọc nội dung theo spec Section 1.4
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusLg,
        ),
        boxShadow: shadow ?? AppShadows.level1,
      ),
      child: child,
    );
  }
}
