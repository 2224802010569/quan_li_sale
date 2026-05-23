import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../entity/order.dart';
import '../screens/shared/order_detail_view.dart';
import 'package:core/theme/theme.dart';

class OrderHistoryCard extends StatelessWidget {
  final Order order;

  const OrderHistoryCard({super.key, required this.order});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  @override
  Widget build(BuildContext context) {
    final createdText = order.createdAt != null
        ? _dateFormat.format(order.createdAt!)
        : '—';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailView(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '#${order.id ?? '—'}',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _currencyFormat.format(order.totalAmount),
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 12),

              // Detail Rows
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                text: createdText,
              ),
              const SizedBox(height: 6),
              _buildDetailRow(
                icon: Icons.store_outlined,
                text: order.storeName ?? 'Cửa hàng #${order.storeId}',
              ),
              if (order.saleName != null && order.saleName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  text: order.saleName!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
