import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:route_store_module/entity/route_detail_entity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreWithDistance {
  final RouteDetailEntity detail;
  final StoreEntity store;
  final double distance;
  final bool isCompleted;

  StoreWithDistance({
    required this.detail,
    required this.store,
    required this.distance,
    required this.isCompleted,
  });
}

class RouteDetailView extends ConsumerWidget {
  final RouteEntity route;
  final void Function(StoreEntity store, RouteEntity route)? onCheckin;

  const RouteDetailView({Key? key, required this.route, this.onCheckin}) : super(key: key);

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Lỗi xác định GPS: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchLocationAndCompletedStores(String userId) async {
    Position? position;
    List<int> completedStoreIds = [];

    if (userId.isNotEmpty) {
      try {
        position = await _determinePosition();
      } catch (e) {
        debugPrint('Lỗi GPS: $e');
      }

      try {
        final supabase = Supabase.instance.client;
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
        final completedResponse = await supabase
            .from('attendance')
            .select('store_id')
            .eq('user_id', userId)
            .gte('created_at', startOfDay)
            .not('checkout_time', 'is', null);

        completedStoreIds = (completedResponse as List).map((e) => e['store_id'] as int).toList();
      } catch (e) {
        debugPrint('Lỗi lấy lịch sử check-out: $e');
      }
    }

    return {
      'position': position,
      'completedStoreIds': completedStoreIds,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user');
    final userId = user?['id']?.toString() ?? '';
    final isSaleRole = (user?['role'] ?? '').toString().toLowerCase() == 'sale';

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchLocationAndCompletedStores(userId),
      builder: (context, snapshot) {
        final dataMap = snapshot.data ?? {'position': null, 'completedStoreIds': <int>[]};
        final Position? position = dataMap['position'];
        final List<int> completedStoreIds = dataMap['completedStoreIds'] ?? [];

        final detailsAsync = ref.watch(realtimeRouteDetailsProvider(route.id));
        final storesAsync = ref.watch(realtimeStoresProvider);
        final routeInfoAsync = ref.watch(routeListWithInfoProvider);

        // Get specific info for this route (assignment, user)
        RouteWithInfo? routeInfo;
        try {
          routeInfo = routeInfoAsync.value?.firstWhere(
            (i) => i.route.id == route.id,
          );
        } catch (_) {}

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

                                    // Tạo danh sách Store với khoảng cách & trạng thái hoàn thành
                                    final List<StoreWithDistance> sortedList = details.map((d) {
                                      final store = allStores.firstWhere(
                                        (s) => s.id == d.storeId,
                                        orElse: () => StoreEntity(
                                          id: d.storeId,
                                          storeName: 'Cửa hàng không tồn tại',
                                          address: 'Đã bị xóa hoặc không tìm thấy',
                                          latitude: 0.0,
                                          longitude: 0.0,
                                          managerId: '',
                                        ),
                                      );
                                      
                                      final isCompleted = completedStoreIds.contains(store.id);
                                      
                                      double distance = 0.0;
                                      if (position != null && store.latitude != 0.0) {
                                        distance = Distance().as(
                                          LengthUnit.Meter,
                                          LatLng(position.latitude, position.longitude),
                                          LatLng(store.latitude, store.longitude),
                                        );
                                      }

                                      return StoreWithDistance(
                                        detail: d,
                                        store: store,
                                        distance: distance,
                                        isCompleted: isCompleted,
                                      );
                                    }).toList();

                                    // Sắp xếp theo:
                                    // 1. Cửa hàng chưa hoàn thành lên trước, đã hoàn thành xuống cuối
                                    // 2. Cửa hàng gần nhất lên trước
                                    sortedList.sort((a, b) {
                                      if (a.isCompleted && !b.isCompleted) return 1;
                                      if (!a.isCompleted && b.isCompleted) return -1;
                                      
                                      if (a.distance == b.distance) {
                                        return a.detail.sequence.compareTo(b.detail.sequence);
                                      }
                                      return a.distance.compareTo(b.distance);
                                    });

                                    return Column(
                                      children: sortedList.map((item) {
                                        final d = item.detail;
                                        final store = item.store;
                                        return _StoreTimelineItem(
                                          index: d.sequence,
                                          storeName: store.storeName,
                                          address: store.address,
                                          isLast: item == sortedList.last,
                                          isSaleRole: isSaleRole,
                                          distance: item.distance,
                                          isCompleted: item.isCompleted,
                                          onCheckinPressed: onCheckin != null ? () {
                                            Navigator.pop(context);
                                            onCheckin!(store, route);
                                          } : null,
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
      },
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
        // Đã xóa thông tin thời gian theo yêu cầu
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
          Builder(
            builder: (context) {
              final avatarPath = saleUser?['avatar_path']?.toString() ?? saleUser?['avatarPath']?.toString() ?? '';
              final avatarUrl = avatarPath.isNotEmpty 
                  ? Supabase.instance.client.storage.from('user_avatars').getPublicUrl(avatarPath)
                  : '';
              return CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFD9E2FF),
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        (saleUser?['full_name'] ?? 'S')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              );
            },
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
  final bool isSaleRole;
  final double distance;
  final bool isCompleted;
  final VoidCallback? onCheckinPressed;

  const _StoreTimelineItem({
    required this.index,
    required this.storeName,
    required this.address,
    required this.isLast,
    this.isSaleRole = false,
    this.distance = 0.0,
    this.isCompleted = false,
    this.onCheckinPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color themeColor = isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF003178);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xFF81C784) : const Color(0xFFB0C6FF),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFE8F5E9).withOpacity(0.5) : const Color(0xFFF3F3FB),
                borderRadius: BorderRadius.circular(24),
                border: isCompleted ? Border.all(color: const Color(0xFFC8E6C9), width: 1) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: TextStyle(
                            color: isCompleted ? const Color(0xFF1B5E20) : const Color(0xFF1A1B21),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: TextStyle(
                            color: isCompleted ? const Color(0xFF4C8C50) : const Color(0xFF434652),
                            fontSize: 14,
                          ),
                        ),
                        if (distance > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Color(0xFF0D47A1)),
                              const SizedBox(width: 4),
                              Text(
                                distance >= 1000
                                    ? 'Cách ${(distance / 1000).toStringAsFixed(1)} km'
                                    : 'Cách ${distance.toStringAsFixed(0)} m',
                                style: const TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Hoàn thành',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isSaleRole && onCheckinPressed != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003178),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: onCheckinPressed,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Check-in', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
