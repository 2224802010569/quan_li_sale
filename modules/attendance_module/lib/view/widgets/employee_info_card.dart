import 'package:flutter/material.dart';
import '../../entity/user.dart';
import 'package:core/theme/theme.dart';

class EmployeeInfoCard extends StatelessWidget {
  final User user;

  const EmployeeInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          // Icon / Avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: user.name.isNotEmpty
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(Icons.person_rounded, color: AppColors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.currentRoute.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.currentRoute,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.isEnoughWorkingDays
                  ? const Color(0xFFdcfce7)
                  : const Color(0xFFfef2f2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              user.isEnoughWorkingDays ? 'ĐỦ CÔNG' : 'THIẾU CÔNG',
              style: AppTextStyles.labelMd.copyWith(
                color: user.isEnoughWorkingDays
                    ? const Color(0xFF16a34a)
                    : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
