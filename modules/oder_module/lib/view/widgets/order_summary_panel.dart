import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:core/theme/theme.dart';

class OrderSummaryPanel extends StatelessWidget {
  final int productCount;
  final int totalQuantity;
  final double subtotal;
  final double vatAmount;
  final double totalAmount;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const OrderSummaryPanel({
    super.key,
    required this.productCount,
    required this.totalQuantity,
    required this.subtotal,
    required this.vatAmount,
    required this.totalAmount,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng kết đơn hàng',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Số lượng sản phẩm:',
            value: '$productCount',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Tổng số lượng (đv):',
            value: '$totalQuantity',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Tạm tính:',
            value: _currencyFormat.format(subtotal),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'VAT (10%):',
            value: _currencyFormat.format(vatAmount),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: AppColors.outlineVariant,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TỔNG CỘNG',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _currencyFormat.format(totalAmount),
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SubmitButton(
            onTap: isSubmitting ? null : onSubmit,
            isSubmitting: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isSubmitting;

  const _SubmitButton({
    required this.onTap,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Hoàn tất & Lưu đơn hàng',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
