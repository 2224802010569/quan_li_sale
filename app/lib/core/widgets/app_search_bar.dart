import 'package:flutter/material.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_styles.dart';

/// Search bar chuẩn Marine Precision — Section 4 (Screen 4)
/// White bg, outline-variant border, radius 16, height 48px
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    this.controller,
    this.placeholder = 'Tìm kiếm...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: onClear,
                  color: AppColors.onSurfaceVariant,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
