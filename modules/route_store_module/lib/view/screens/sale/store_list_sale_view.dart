import 'package:flutter/material.dart';
import '../../../entity/store_item.dart';
import '../../../logic_uc/store_list_uc.dart';
import '../../../output/route_store_output.dart';

class StoreListSaleView extends StatefulWidget {
  final String userId;
  final Function(RouteStoreOutput) onOutput;

  const StoreListSaleView({
    super.key,
    required this.userId,
    required this.onOutput,
  });

  @override
  State<StoreListSaleView> createState() => _StoreListSaleViewState();
}

class _StoreListSaleViewState extends State<StoreListSaleView> {
  final _uc = StoreListUC();

  List<StoreItem> _stores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stores = await _uc.getStoresForToday(widget.userId);
      if (mounted) {
        setState(() {
          _stores = stores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cửa hàng hôm nay',
          style: TextStyle(
            color: Color(0xFF0F3C8F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F3C8F)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF434651),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadStores,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3C8F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 56, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Không có cửa hàng được\nphân công hôm nay',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0F3C8F),
      onRefresh: _loadStores,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stores.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildStoreCard(_stores[index]),
      ),
    );
  }

  Widget _buildStoreCard(StoreItem store) {
    return Opacity(
      opacity: store.isCompleted ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: () {
          widget.onOutput(RouteStoreOutput(
            action: 'CHECKIN',
            storeId: store.id,
            storeName: store.name,
            routeId: store.routeId,
            routeName: store.routeName,
            latitude: store.latitude,
            longitude: store.longitude,
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Số thứ tự
              CircleAvatar(
                radius: 20,
                backgroundColor: store.isCompleted
                    ? const Color(0xFF22C55E).withOpacity(0.12)
                    : const Color(0xFF0F3C8F).withOpacity(0.10),
                child: Text(
                  '${store.sequence}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: store.isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF0F3C8F),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Tên cửa hàng + tuyến
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      store.routeName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing icon
              store.isCompleted
                  ? const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 22)
                  : const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
