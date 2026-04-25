import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x1E0D47A1),
            blurRadius: 48,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng kết đơn hàng',
            style: TextStyle(
              color: Color(0xFF172554),
              fontSize: 20,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              height: 1.40,
              letterSpacing: -0.50,
            ),
          ),
          const SizedBox(height: 24),
          _SummaryRow(
            label: 'Số lượng sản phẩm:',
            value: '$productCount',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Tổng số lượng (đv):',
            value: '$totalQuantity',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Tạm tính:',
            value: _currencyFormat.format(subtotal),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'VAT (10%):',
            value: _currencyFormat.format(vatAmount),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Color(0xFFE8E8E8),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'TỔNG CỘNG',
                  style: TextStyle(
                    color: Color(0xFF172554),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                    letterSpacing: 1.40,
                  ),
                ),
                Text(
                  _currencyFormat.format(totalAmount),
                  style: const TextStyle(
                    color: Color(0xFF001D4E),
                    fontSize: 30,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w900,
                    height: 1.20,
                    letterSpacing: -1.50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          style: const TextStyle(
            color: Color(0xFF434651),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF434651),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            height: 1.50,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.45, -0.45),
            end: Alignment(0.55, 1.45),
            colors: [Color(0xFF001D4E), Color(0xFF003178)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x331E3A8A),
              blurRadius: 10,
              offset: Offset(0, 8),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Color(0x331E3A8A),
              blurRadius: 25,
              offset: Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Hoàn tất & Lưu đơn hàng',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
        ),
      ),
    );
  }
}
