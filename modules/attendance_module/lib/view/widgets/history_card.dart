import 'package:flutter/material.dart';
import '../../entity/attendance.dart';
import 'package:core/theme/theme.dart';

class HistoryCard extends StatelessWidget {
  final Attendance attendance;

  const HistoryCard({super.key, required this.attendance});

  String _formatTime(DateTime time) {
    String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour == 0 ? 12 : time.hour}';
    hour = hour.padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    String amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = attendance.status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Strip: CHECK-IN | CHECK-OUT ──
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    // CHECK-IN image
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            attendance.checkinImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_rounded, size: 36, color: AppColors.outlineVariant),
                              ),
                            ),
                          ),
                          // Badge
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Color(0x99000000),
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                              ),
                              child: Text(
                                'CHECK-IN',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Separator
                    Container(width: 2, color: AppColors.white),
                    // CHECK-OUT image
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Builder(builder: (context) {
                            final hasPhoto = attendance.checkoutImage.isNotEmpty;

                            if (!isCompleted) {
                              return Container(
                                color: AppColors.surfaceContainerLow,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.pending_actions_rounded, size: 36, color: AppColors.secondary),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Chờ check-out',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            } else if (hasPhoto) {
                              return Image.network(
                                attendance.checkoutImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildCheckedOutPlaceholder(),
                              );
                            } else {
                              return _buildCheckedOutPlaceholder();
                            }
                          }),
                          // Badge
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted ? AppColors.secondary : const Color(0x99000000),
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                              ),
                              child: Text(
                                'CHECK-OUT',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content Area ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store name + timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            attendance.storeName,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(attendance.time),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Route/Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attendance.locationAddress,
                            style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCompleted ? const Color(0xFFdcfce7) : const Color(0xFFfef2f2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            isCompleted ? 'HOÀN TẤT' : 'PENDING',
                            style: AppTextStyles.labelMd.copyWith(
                              color: isCompleted ? const Color(0xFF16a34a) : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Refresh FAB (if PENDING) ──
          if (!isCompleted)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.level2,
                ),
                child: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckedOutPlaceholder() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 36, color: Color(0xFF16a34a)),
          const SizedBox(height: 6),
          Text(
            'Đã Check-out',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(
              color: const Color(0xFF16a34a),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
