import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import '../../../logic_data/order_data.dart';
import '../../../entity/order.dart';
import '../../widgets/order_history_card.dart';

class OrderHistoryView extends StatefulWidget {
  final OrderData orderData;
  final int? storeId;
  final String? userId;
  final String role;
  final String? groupId;
  final VoidCallback onBack;

  const OrderHistoryView({
    super.key,
    required this.orderData,
    this.storeId,
    this.userId,
    required this.role,
    this.groupId,
    required this.onBack,
  });

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Map<String, dynamic>> _teamSales = [];
  List<String> _teamSaleIds = [];
  String? _selectedSaleId;
  bool _isInitLoading = true;

  final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  final _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    String? effectiveGroupId = widget.groupId;

    // Fallback: nếu groupId null, thử lấy từ AppStorage
    if (widget.role == 'Manager' && effectiveGroupId == null) {
      try {
        final user = get<AppStorage>().get<Map<String, dynamic>>('user');
        effectiveGroupId = user?['groupId']?.toString();
      } catch (e) {
        debugPrint('[OrderHistoryView] Không thể lấy groupId từ AppStorage: $e');
      }
    }

    debugPrint('[OrderHistoryView] groupId = $effectiveGroupId');

    if (widget.role == 'Manager' && effectiveGroupId != null) {
      try {
        _teamSales = await widget.orderData.getSalesInGroup(effectiveGroupId);
        _teamSaleIds = _teamSales.map((s) => s['id'] as String).toList();
      } catch (e) {
        debugPrint('[OrderHistoryView] Lỗi khi load teamSales: $e');
      }
    }

    debugPrint('[OrderHistoryView] _teamSales.length = ${_teamSales.length}');
    debugPrint('[OrderHistoryView] _teamSaleIds = $_teamSaleIds');

    setState(() {
      _isInitLoading = false;
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Manager: chỉ dùng _selectedSaleId khi chọn cụ thể 1 nhân viên
      // Không dùng widget.userId làm fallback — sẽ gây filter sai thành manager_id
      final String? filterUserId = widget.role == 'Manager'
          ? _selectedSaleId  // null = "Tất cả" → dùng userIds
          : (_selectedSaleId ?? widget.userId);

      final response = await widget.orderData.getOrderHistory(
        storeId: widget.storeId,
        userId: filterUserId,
        userIds: (widget.role == 'Manager' && filterUserId == null)
            ? _teamSaleIds
            : null,
        month: _selectedMonth,
      );
      setState(() {
        _orders = response.map((e) => Order.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải lịch sử đơn hàng';
        _isLoading = false;
      });
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF172554)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Lịch sử đơn hàng',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF003178)));
    }

    return Column(
      children: [
        if (widget.role == 'Manager')
          _buildFilterDropdown(),
        _buildMonthFilterRow(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildMonthFilterRow() {
    final currentMonth = DateTime.now();
    final months = [
      DateTime(currentMonth.year, currentMonth.month, 1),
      DateTime(currentMonth.year, currentMonth.month - 1, 1),
      DateTime(currentMonth.year, currentMonth.month - 2, 1),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: months.map((m) {
          final isSelected = _selectedMonth.year == m.year && _selectedMonth.month == m.month;
          final title = m.year == currentMonth.year && m.month == currentMonth.month 
              ? 'Tháng hiện tại' 
              : 'Tháng ${m.month}/${m.year}';
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMonth = m;
                });
                _loadHistory();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF001D4E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF434651),
                    fontFamily: 'Manrope',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LỌC NHÂN VIÊN',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _selectedSaleId,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tất cả nhân viên', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    ..._teamSales.map((sale) {
                      return DropdownMenuItem<String?>(
                        value: sale['id'],
                        child: Text(sale['full_name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedSaleId = val;
                    });
                    _loadHistory();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF003178)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFF434651),
                fontSize: 16,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003178),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                color: Color(0xFF434651),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF003178),
      onRefresh: () async {
        await _loadHistory();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return OrderHistoryCard(order: order);
  }
}
