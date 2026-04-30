import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../entity/order.dart';
import '../../../entity/order_item.dart';

class OrderDetailView extends StatelessWidget {
  final Order order;

  const OrderDetailView({super.key, required this.order});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdText = order.createdAt != null
        ? _dateFormat.format(order.createdAt!)
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF172554)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: Color(0xFF172554),
            fontSize: 24,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: -1.20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfoCard(createdText),
            const SizedBox(height: 24),
            _buildSectionTitle('SẢN PHẨM'),
            const SizedBox(height: 12),
            _buildItemsList(),
            if (order.orderImage != null && order.orderImage!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('ẢNH CHỤP'),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  order.orderImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF003178)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              size: 40, color: Color(0xFF94A3B8)),
                          SizedBox(height: 8),
                          Text(
                            'Không thể tải ảnh',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(String createdText) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã đơn: #${order.id ?? '—'}',
                style: const TextStyle(
                  color: Color(0xFF172554),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _currencyFormat.format(order.totalAmount),
                style: const TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F3F3)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                createdText,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.store_outlined,
                  size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                order.storeName ?? 'Cửa hàng #${order.storeId}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF434651),
        fontSize: 14,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        height: 1.43,
        letterSpacing: 1.40,
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFF3F3F3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? 'Sản phẩm #${item.productId}',
                      style: const TextStyle(
                        color: Color(0xFF172554),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} x ${_currencyFormat.format(item.unitPrice)}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currencyFormat.format(item.unitPrice * item.quantity),
                style: const TextStyle(
                  color: Color(0xFF003178),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
