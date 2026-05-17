import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';

class RouteDetailView extends ConsumerWidget {
  final RouteEntity route;

  const RouteDetailView({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(realtimeRouteDetailsProvider(route.id));
    final storesAsync = ref.watch(realtimeStoresProvider);
    final routeInfoAsync = ref.watch(routeListWithInfoProvider);

    // Get specific info for this route (assignment, user)
    final routeInfo = routeInfoAsync.value?.firstWhere(
      (i) => i.route.id == route.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          // ==================== CONTENT ====================
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRouteTitle(),
                        const SizedBox(height: 32),
                        if (routeInfo != null) _buildAssignmentInfo(routeInfo),
                        const SizedBox(height: 32),
                        const Text(
                          'Lộ trình cửa hàng',
                          style: TextStyle(
                            color: Color(0xFF1A1B21),
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        detailsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text('Lỗi: $err')),
                          data: (details) {
                            return storesAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (err, _) =>
                                  Center(child: Text('Lỗi tải cửa hàng: $err')),
                              data: (allStores) {
                                if (details.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Chưa có cửa hàng nào trong tuyến này',
                                    ),
                                  );
                                }
                                return Column(
                                  children: details.map((d) {
                                    final store = allStores.firstWhere(
                                      (s) => s.id == d.storeId,
                                    );
                                    return _StoreTimelineItem(
                                      index: d.sequence,
                                      storeName: store.storeName,
                                      address: store.address,
                                      isLast: d == details.last,
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================== APP BAR ====================
          Positioned(left: 0, top: 0, right: 0, child: _buildAppBar(context)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xD8FAF8FF),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1A1B21),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Chi tiết Lộ trình',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0D47A1)),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          route.routeName,
          style: const TextStyle(
            color: Color(0xFF1A1B21),
            fontSize: 30,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.75,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Color(0xFF434652)),
            SizedBox(width: 8),
            Text(
              'Thứ 2, 08:30 AM',
              style: TextStyle(
                color: Color(0xFF434652),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssignmentInfo(RouteWithInfo info) {
    final saleUser = info.saleUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A1B21),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFD9E2FF),
            child: Text(
              (saleUser?['full_name'] ?? 'S')[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhân viên phụ trách',
                  style: TextStyle(color: Color(0xFF434652), fontSize: 12),
                ),
                Text(
                  saleUser?['full_name'] ?? 'Chưa phân công',
                  style: const TextStyle(
                    color: Color(0xFF1A1B21),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (info.assignment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD9E2FF),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Text(
                'Chính thức',
                style: TextStyle(
                  color: Color(0xFF00429C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreTimelineItem extends StatelessWidget {
  final int index;
  final String storeName;
  final String address;
  final bool isLast;

  const _StoreTimelineItem({
    required this.index,
    required this.storeName,
    required this.address,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF003178),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFB0C6FF)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3FB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      color: Color(0xFF1A1B21),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Color(0xFF434652),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
