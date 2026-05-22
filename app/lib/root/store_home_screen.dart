import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:core/di/supabase.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_styles.dart';
import 'package:core/theme/app_shadows.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:oder_module/entity/order.dart';
import 'package:intl/intl.dart';
import 'package:app/root/app_output.dart';
import 'package:app/core/widgets/app_status_badge.dart';
import 'package:app/core/widgets/app_card.dart';

class StoreHomeScreen extends ConsumerStatefulWidget {
  final Function(AppOutput) onNavigate;
  const StoreHomeScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  ConsumerState<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends ConsumerState<StoreHomeScreen> {
  bool _isLoading = true;
  StoreEntity? _store;
  double _todayTotal = 0.0;
  List<Order> _recentOrders = [];

  final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN', symbol: 'đ', decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final storage  = get<AppStorage>();
      final supabase = get<SupabaseConnect>().client!;
      final storeId  = storage.get<int>('current_store_id') ?? 0;
      final storeName= storage.get<String>('current_store_name') ?? '';

      StoreEntity? store;
      if (storeId > 0) {
        try {
          final res = await supabase.from('stores').select().eq('id', storeId).single();
          store = StoreEntity.fromMap(res);
        } catch (_) {}
      }
      _store = store ?? StoreEntity(
        id: storeId,
        storeName: storeName.isNotEmpty ? storeName : 'VinMart Central Park',
        address: 'L01-02, Tòa Landmark 81, 720A Điện Biên Phủ, Bình Thạnh, TP. HCM',
        latitude: 10.795, longitude: 106.722, managerId: '',
      );

      double todayTotal = 0.0;
      if (storeId > 0) {
        try {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
          final res = await supabase.from('orders').select('total_amount')
              .eq('store_id', storeId).gte('created_at', todayStart);
          for (var o in res) todayTotal += (o['total_amount'] as num?)?.toDouble() ?? 0.0;
        } catch (_) {}
      }
      _todayTotal = todayTotal;

      List<Order> orders = [];
      if (storeId > 0) {
        try {
          final res = await supabase.from('orders')
              .select('*, stores(store_name), users(full_name), order_items(*)')
              .eq('store_id', storeId).order('created_at', ascending: false).limit(3);
          orders = (res as List).map((e) => Order.fromMap(e)).toList();
        } catch (_) {}
      }
      _recentOrders = orders;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.storefront_outlined, size: 18, color: AppColors.secondary),
        ),
        title: Text(
          _store?.storeName ?? 'Cửa hàng',
          style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.secondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: AppSpacing.stackGap),
              _buildRevenueBanner(),
              const SizedBox(height: AppSpacing.stackGap),
              _buildCtaButton(),
              const SizedBox(height: AppSpacing.stackGap),
              _buildQuickActions(),
              const SizedBox(height: AppSpacing.xxl),
              _buildRecentOrdersSection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Card ────────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _store?.storeName ?? '',
                  style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurface),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Badge ACTIVE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'ACTIVE',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.statusActiveText),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _store?.address ?? '',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Revenue Banner ─────────────────────────────────────────────────────────
  Widget _buildRevenueBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer, // #0d3b7a dark navy
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOANH SỐ TẠI ĐIỂM HÔM NAY',
            style: AppTextStyles.labelLg.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  _currencyFormat.format(_todayTotal),
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700,
                    color: AppColors.white, fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),
              // Trend chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 12, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Hôm nay',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.white),
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

  // ── CTA — Lên đơn hàng ────────────────────────────────────────────────────
  Widget _buildCtaButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => widget.onNavigate(AppOutput(toModule: 'CREATE_ORDER')),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, color: AppColors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'LÊN ĐƠN HÀNG',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionTile(
          label: 'Kiểm tồn kho',
          subLabel: 'INVENTORY',
          icon: Icons.inventory_2_outlined,
          bgColor: AppColors.surfaceContainerLow,
          fgColor: AppColors.onSurface,
          iconColor: AppColors.secondary,
          onTap: () => widget.onNavigate(AppOutput(toModule: 'INVENTORY')),
        )),
        const SizedBox(width: AppSpacing.stackGap),
        Expanded(child: _buildActionTile(
          label: 'Checkout',
          subLabel: 'END VISIT',
          icon: Icons.exit_to_app_rounded,
          bgColor: AppColors.statusRejectedBg, // #fff0f0 đỏ nhạt
          fgColor: AppColors.error,
          iconColor: AppColors.error,
          onTap: () => widget.onNavigate(AppOutput(toModule: 'CHECKOUT')),
        )),
      ],
    );
  }

  Widget _buildActionTile({
    required String label,
    required String subLabel,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelMd.copyWith(color: fgColor, fontWeight: FontWeight.w600)),
            Text(subLabel, style: AppTextStyles.caption.copyWith(color: fgColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  // ── Recent Orders ──────────────────────────────────────────────────────────
  Widget _buildRecentOrdersSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ĐƠN HÀNG GẦN ĐÂY',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurface)),
            GestureDetector(
              onTap: () {
                if (_store != null) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StoreOrderHistoryScreen(
                      store: _store!, currencyFormat: _currencyFormat,
                    ),
                  ));
                }
              },
              child: Text('Xem tất cả',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                )),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackGap),
        if (_recentOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text('Chưa có đơn hàng nào',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            ),
          )
        else
          ..._recentOrders.map(_buildOrderCard),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final timeStr = order.createdAt != null
        ? DateFormat('HH:mm').format(order.createdAt!)
        : '--:--';
    final isToday = order.createdAt?.day == DateTime.now().day;
    final dateLabel = isToday ? timeStr : DateFormat('dd/MM').format(order.createdAt!);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.stackGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#ORD-${order.id}',
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text('$dateLabel • ${order.items.length} sản phẩm',
                    style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currencyFormat.format(order.totalAmount),
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              const SizedBox(height: 4),
              const AppStatusBadge(label: 'HOÀN TẤT', status: AppBadgeStatus.active),
            ],
          ),
        ],
      ),
    );
  }
}

// ── StoreOrderHistoryScreen ────────────────────────────────────────────────
class StoreOrderHistoryScreen extends StatefulWidget {
  final StoreEntity store;
  final NumberFormat currencyFormat;
  const StoreOrderHistoryScreen({Key? key, required this.store, required this.currencyFormat}) : super(key: key);

  @override
  State<StoreOrderHistoryScreen> createState() => _StoreOrderHistoryScreenState();
}

class _StoreOrderHistoryScreenState extends State<StoreOrderHistoryScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() { super.initState(); _fetchMonthOrders(); }

  Future<void> _fetchMonthOrders() async {
    try {
      final supabase = get<SupabaseConnect>().client!;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
      final res = await supabase.from('orders')
          .select('*, stores(store_name), users(full_name), order_items(*)')
          .eq('store_id', widget.store.id ?? 0)
          .gte('created_at', startOfMonth)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _orders = (res as List).map((e) => Order.fromMap(e)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _orders = []; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStr = 'Tháng ${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(children: [
          Text('Lịch sử đơn hàng',
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface)),
          Text(monthStr,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
        ]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : _orders.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow, shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.outlineVariant),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Chưa có đơn hàng nào',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Các đơn hàng sẽ hiển thị tại đây.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMonthOrders,
                  color: AppColors.secondary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.containerMargin),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) {
                      final order = _orders[i];
                      final timeStr = order.createdAt != null
                          ? DateFormat('dd/MM/yyyy • HH:mm').format(order.createdAt!)
                          : 'Chưa rõ ngày';
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          boxShadow: AppShadows.level1,
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.stackGap),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, size: 24, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#ORD-${order.id}',
                                  style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                              const SizedBox(height: 4),
                              Text('$timeStr • ${order.items.length} sản phẩm',
                                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          )),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(widget.currencyFormat.format(order.totalAmount),
                                style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            const SizedBox(height: AppSpacing.sm),
                            const AppStatusBadge(label: 'HOÀN TẤT', status: AppBadgeStatus.active),
                          ]),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }
}
