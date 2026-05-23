import 'package:flutter/material.dart';
import 'package:inventory_module/entity/product_entity.dart';

class InventorySummaryScreen extends StatelessWidget {
  final Map<String, int> actualStocks;
  final Map<String, int> previousStocks;
  final List<dynamic> products; // List<ProductEntity>
  final VoidCallback onDone;
  final VoidCallback onCreateOrder;

  const InventorySummaryScreen({
    Key? key,
    required this.actualStocks,
    required this.previousStocks,
    required this.products,
    required this.onDone,
    required this.onCreateOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typedProducts = products.whereType<ProductEntity>().toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kết quả kiểm tồn',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header tổng kết
          _buildSummaryHeader(typedProducts),
          // Bảng danh sách sản phẩm
          Expanded(
            child: typedProducts.isEmpty
                ? _buildEmptyProducts()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: typedProducts.length,
                    itemBuilder: (_, i) => _buildProductRow(typedProducts[i]),
                  ),
          ),
          // Nút hành động
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(List<ProductEntity> typedProducts) {
    int increased = 0, decreased = 0, unchanged = 0;
    for (final p in typedProducts) {
      final actual = actualStocks[p.id] ?? 0;
      final previous = previousStocks[p.id] ?? 0;
      if (actual > previous) increased++;
      else if (actual < previous) decreased++;
      else unchanged++;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3C8F), Color(0xFF1A56DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('Tăng', increased, const Color(0xFF86EFAC)),
          _buildStatChip('Giảm', decreased, const Color(0xFFFCA5A5)),
          _buildStatChip('Bằng', unchanged, const Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Không có sản phẩm để hiển thị',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(ProductEntity product) {
    final actual = actualStocks[product.id] ?? 0;
    final previous = previousStocks[product.id] ?? 0;
    final diff = actual - previous;

    Color diffColor;
    String diffText;
    IconData diffIcon;

    if (diff > 0) {
      diffColor = const Color(0xFF16A34A);
      diffText = '+$diff';
      diffIcon = Icons.arrow_upward_rounded;
    } else if (diff < 0) {
      diffColor = const Color(0xFFDC2626);
      diffText = '$diff';
      diffIcon = Icons.arrow_downward_rounded;
    } else {
      diffColor = const Color(0xFF94A3B8);
      diffText = '0';
      diffIcon = Icons.remove_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Tên sản phẩm
          Expanded(
            flex: 3,
            child: Text(
              product.productName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Tồn trước
          Expanded(
            child: Text(
              '$previous',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Tồn nay
          Expanded(
            child: Text(
              '$actual',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3C8F),
              ),
            ),
          ),
          // Chênh lệch
          SizedBox(
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(diffIcon, size: 14, color: diffColor),
                const SizedBox(width: 2),
                Text(
                  diffText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: diffColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Về trang chủ
          Expanded(
            child: OutlinedButton(
              onPressed: onDone,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF0F3C8F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Về trang chủ',
                style: TextStyle(
                  color: Color(0xFF0F3C8F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Lên đơn hàng
          Expanded(
            child: ElevatedButton(
              onPressed: onCreateOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF0F3C8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Lên đơn hàng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row cho bảng sản phẩm — dùng như SliverPersistentHeader nếu cần
class InventorySummaryTableHeader extends StatelessWidget {
  const InventorySummaryTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF1F5F9),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Sản phẩm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          Expanded(child: Text('Trước', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          Expanded(child: Text('Nay', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
          SizedBox(width: 64, child: Text('±', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
        ],
      ),
    );
  }
}
