import 'package:flutter/material.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_styles.dart';

/// Trạng thái cho AppStatusBadge
enum AppBadgeStatus {
  active,    // ACTIVE / HOÀN TẤT   — xanh lá
  pending,   // ĐANG XỬ LÝ / PENDING — cam
  assigned,  // ĐÃ XÁC NHẬN / ASSIGNED — xanh dương
  rejected,  // TỪ CHỐI / NỢ QUÁ HẠN — đỏ
  newStore,  // KHÁCH HÀNG MỚI — xanh dương nhạt
}

/// Status Badge System — Section 4 của update_UI.md
/// Pill badge tự động chọn màu theo trạng thái.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final AppBadgeStatus status;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.status,
  });

  /// Tạo badge từ string trạng thái (case-insensitive)
  factory AppStatusBadge.fromString(String status) {
    final s = status.toLowerCase();
    if (s.contains('hoàn') || s.contains('active') || s.contains('done')) {
      return AppStatusBadge(label: status.toUpperCase(), status: AppBadgeStatus.active);
    }
    if (s.contains('pending') || s.contains('xử lý') || s.contains('chờ')) {
      return AppStatusBadge(label: status.toUpperCase(), status: AppBadgeStatus.pending);
    }
    if (s.contains('assigned') || s.contains('xác nhận')) {
      return AppStatusBadge(label: status.toUpperCase(), status: AppBadgeStatus.assigned);
    }
    if (s.contains('từ chối') || s.contains('nợ') || s.contains('reject')) {
      return AppStatusBadge(label: status.toUpperCase(), status: AppBadgeStatus.rejected);
    }
    return AppStatusBadge(label: status.toUpperCase(), status: AppBadgeStatus.newStore);
  }

  Color get _backgroundColor {
    switch (status) {
      case AppBadgeStatus.active:   return AppColors.statusActiveBg;
      case AppBadgeStatus.pending:  return AppColors.statusPendingBg;
      case AppBadgeStatus.assigned: return AppColors.statusAssignedBg;
      case AppBadgeStatus.rejected: return AppColors.statusRejectedBg;
      case AppBadgeStatus.newStore: return AppColors.statusNewBg;
    }
  }

  Color get _textColor {
    switch (status) {
      case AppBadgeStatus.active:   return AppColors.statusActiveText;
      case AppBadgeStatus.pending:  return AppColors.statusPendingText;
      case AppBadgeStatus.assigned: return AppColors.statusAssignedText;
      case AppBadgeStatus.rejected: return AppColors.statusRejectedText;
      case AppBadgeStatus.newStore: return AppColors.statusNewText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2, // 10px
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelMd.copyWith(color: _textColor),
      ),
    );
  }
}
