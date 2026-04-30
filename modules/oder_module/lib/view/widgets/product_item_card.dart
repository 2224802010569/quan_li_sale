import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../entity/product.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A0D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F3F3)),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            product.productName,
            style: const TextStyle(
              color: Color(0xFF172554),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3F3F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        _showQuantityDialog(context, quantity, onUpdateQuantity);
                      },
                      child: SizedBox(
                        width: 48,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w900,
                            height: 1.50,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Đơn giá: ${_currencyFormat.format(product.price)}',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(lineTotal),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF172554),
                        fontSize: 18,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w900,
                        height: 1.56,
                      ),
                    ),
                  ],
                ),
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
          title: const Text('Nhập số lượng'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Số lượng',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                onSaved(val);
                Navigator.pop(ctx);
              },
              child: const Text('Xác nhận'),
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
        width: 32,
        height: 32,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }
}
