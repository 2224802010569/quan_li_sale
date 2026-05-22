import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../entity/product.dart';
import 'package:core/theme/theme.dart';

class ProductItemCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onUpdateQuantity;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onUpdateQuantity,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final lineTotal = product.price * quantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 24,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  product.productName,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onTap: onDecrement,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _showQuantityDialog(context, quantity, onUpdateQuantity);
                      },
                      child: Container(
                        width: 44,
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Đơn giá: ${_currencyFormat.format(product.price)}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currencyFormat.format(lineTotal),
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, int initialValue, ValueChanged<int> onSaved) {
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'Nhập số lượng',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              labelText: 'Số lượng',
              labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Hủy',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                onSaved(val);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
              ),
              child: Text(
                'Xác nhận',
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.level1,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
