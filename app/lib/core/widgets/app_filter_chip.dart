import 'package:flutter/material.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_styles.dart';

/// Filter chip chuẩn Marine Precision — Section 5 (Screen 5, 8, 12)
/// Active: primary bg #002556 + white text
/// Inactive: white bg + outline-variant border
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLg.copyWith(
            color: isActive ? AppColors.white : AppColors.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Row nhiều filter chips — tự wrap ngang
class AppFilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const AppFilterChipRow({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              right: entry.key < labels.length - 1 ? AppSpacing.sm : 0,
            ),
            child: AppFilterChip(
              label: entry.value,
              isActive: entry.key == activeIndex,
              onTap: () => onChanged(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
