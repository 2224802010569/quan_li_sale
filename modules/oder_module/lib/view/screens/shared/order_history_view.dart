import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import '../../../logic_data/order_data.dart';
import '../../../entity/order.dart';
import '../../widgets/order_history_card.dart';
import 'package:core/theme/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    String? effectiveGroupId = widget.groupId;

    if (widget.role == 'Manager' && effectiveGroupId == null) {
      try {
        final user = get<AppStorage>().get<Map<String, dynamic>>('user');
        effectiveGroupId = user?['groupId']?.toString();
      } catch (e) {
        debugPrint('[OrderHistoryView] Không thể lấy groupId từ AppStorage: $e');
      }
    }

    if (widget.role == 'Manager' && effectiveGroupId != null) {
      try {
        _teamSales = await widget.orderData.getSalesInGroup(effectiveGroupId);
        _teamSaleIds = _teamSales.map((s) => s['id'] as String).toList();
      } catch (e) {
        debugPrint('[OrderHistoryView] Lỗi khi load teamSales: $e');
      }
    }

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
      final String? filterUserId = widget.role == 'Manager'
          ? _selectedSaleId
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Lịch sử đơn hàng',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: months.map((m) {
          final isSelected = _selectedMonth.year == m.year && _selectedMonth.month == m.month;
          final title = m.year == currentMonth.year && m.month == currentMonth.month 
              ? 'Tháng hiện tại' 
              : 'Tháng ${m.month}/${m.year}';
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
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
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected ? null : Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LỌC NHÂN VIÊN',
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _selectedSaleId,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                dropdownColor: AppColors.white,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tất cả nhân viên', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
                  ),
                  ..._teamSales.map((sale) {
                    return DropdownMenuItem<String?>(
                      value: sale['id'],
                      child: Text(sale['full_name'] ?? 'Không tên', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
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
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Text(
                'Thử lại',
                style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
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
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.outlineVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng nào',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async {
        await _loadHistory();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerMargin,
          vertical: AppSpacing.lg,
        ),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.stackGap),
        itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return OrderHistoryCard(order: order);
  }
}
