import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kpi_module/entity/kpi_report_entity.dart';
import 'package:kpi_module/logic_uc/manage_kpi_uc.dart';
import 'package:kpi_module/logic_uc/generate_kpi_pdf_uc.dart';
import 'package:intl/intl.dart';

class KpiDetailView extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final int month;
  final int year;

  const KpiDetailView({
    Key? key,
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
  }) : super(key: key);

  @override
  ConsumerState<KpiDetailView> createState() => _KpiDetailViewState();
}

class _KpiDetailViewState extends ConsumerState<KpiDetailView> {
  KpiReportEntity? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final r = await ref.read(manageKpiUcProvider).fetchKpiReport(
            widget.userId,
            widget.userName,
            widget.month,
            widget.year,
          );
      setState(() {
        _report = r;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _exportPdf() async {
    if (_report == null) return;
    try {
      await GenerateKpiPdfUc().generateAndPrintPdf(_report!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tạo PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Chi tiết KPI', style: TextStyle(color: Color(0xFF001D4E), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF001D4E)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _report == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Chi tiết KPI', style: TextStyle(color: Color(0xFF001D4E), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF001D4E)),
        ),
        body: Center(child: Text('Lỗi: $_error')),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final r = _report!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(r.userName, style: const TextStyle(color: Color(0xFF001D4E), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF001D4E)),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Xuất báo cáo PDF',
              onPressed: _exportPdf,
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF001D4E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF001D4E),
            tabs: [
              Tab(text: 'Danh sách Đơn hàng'),
              Tab(text: 'Ảnh minh chứng'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSummaryHeader(r, currencyFormat),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrdersList(r.orders, currencyFormat),
                  _buildVisualDocumentation(r.proofImageUrls),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(KpiReportEntity r, NumberFormat currencyFormat) {
    final isComplete = r.percentCompleted >= 100;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildSummaryItem('MỤC TIÊU', currencyFormat.format(r.targetRevenue), const Color(0xFF434651))),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryItem('THỰC ĐẠT', currencyFormat.format(r.actualRevenue), const Color(0xFF001D4E))),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryItem(
            'TIẾN ĐỘ',
            '${r.percentCompleted.toStringAsFixed(1)}%',
            isComplete ? const Color(0xFF059669) : const Color(0xFFE6845D),
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, NumberFormat currencyFormat) {
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào trong tháng này.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final id = order['id'] ?? 'N/A';
        final storeId = order['store_id'] ?? 'N/A';
        final total = currencyFormat.format((order['total_amount'] ?? 0).toDouble());
        final date = order['created_at'] != null ? order['created_at'].toString().split('T')[0] : '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x19C4C6D2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F3F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long, color: Color(0xFF001D4E), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #$id',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF001D4E),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cửa hàng #$storeId • $date',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisualDocumentation(List<String> urls) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VISUAL DOCUMENTATION',
            style: TextStyle(
              color: Color(0xFF1E448B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.40,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toàn bộ hình ảnh\nđơn hàng',
            style: TextStyle(
              color: Color(0xFF001D4E),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.11,
              letterSpacing: -0.90,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Color(0xFF1A1C1C), size: 20),
                const SizedBox(width: 12),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (urls.isEmpty)
            const Center(child: Text('Không có ảnh minh chứng nào.', style: TextStyle(color: Colors.grey)))
          else
            _buildMasonryGrid(urls),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(List<String> urls) {
    // Để tái hiện giao diện Masonry Grid / Staggered một cách đơn giản không dùng thư viện ngoài,
    // ta dùng Wrap hoặc Column kết hợp Row.
    // Dưới đây là GridView.builder 2 cột đơn giản mang phong cách của thiết kế.
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, // Hình vuông
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final url = urls[index];
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            );
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
                // Gradient mờ ở dưới
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 60,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PHOTO #${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge nhỏ ở góc (như DELIVERED / ORDER)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: Text(
                      index % 2 == 0 ? 'CHECK-IN' : 'ORDER',
                      style: const TextStyle(
                        color: Color(0xFF001D4E),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
