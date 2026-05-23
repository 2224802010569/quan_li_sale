import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core/theme/theme.dart';

class CameraCaptureBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onCapture;
  final VoidCallback? onRemove;

  const CameraCaptureBox({
    super.key,
    this.imagePath,
    required this.onCapture,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return _buildPreview();
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Slate 900
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: AppColors.white.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Vui lòng chụp ảnh đơn hàng hoặc phiếu\ngiao nhận thực tế',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.white.withValues(alpha: 0.50),
                height: 1.43,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCapture,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.10),
                border: Border.all(
                  width: 1,
                  color: AppColors.white.withValues(alpha: 0.20),
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bắt đầu chụp',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.level2,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onCapture,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.80),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Chụp lại',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
