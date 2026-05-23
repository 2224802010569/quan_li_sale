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
import 'package:core/theme/theme.dart';

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
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // ==================== CONTENT ====================
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerMargin,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRouteTitle(),
                            const SizedBox(height: AppSpacing.xxxl),
                            if (routeInfo != null) _buildAssignmentInfo(routeInfo),
                            const SizedBox(height: AppSpacing.xxxl),
                            Row(
                              children: [
                                Text(
                                  'Lộ trình cửa hàng',
                                  style: AppTextStyles.headlineSm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                detailsAsync.maybeWhen(
                                  data: (details) => Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    child: Text(
                                      '${details.length} Cửa hàng',
                                      style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
                                    ),
                                  ),
                                  orElse: () => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            detailsAsync.when(
                              loading: () =>
                                  const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                              error: (err, _) => Center(child: Text('Lỗi: $err', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
                              data: (details) {
                                return storesAsync.when(
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(color: AppColors.secondary),
                                  ),
                                  error: (err, _) =>
                                      Center(child: Text('Lỗi tải cửa hàng: $err', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error))),
                                  data: (allStores) {
                                    if (details.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 32),
                                          child: Text(
                                            'Chưa có cửa hàng nào trong tuyến này',
                                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                                          ),
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
        color: AppColors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Chi tiết Lộ trình',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.map_outlined, color: AppColors.secondary),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.routeName,
                style: AppTextStyles.headlineLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hành trình bán hàng hằng ngày',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentInfo(RouteWithInfo info) {
    final saleUser = info.saleUser;
    final String employeeCode = saleUser?['employee_code']?.toString() ?? 'SKM-992';
    final avatarPath = saleUser?['avatar_path']?.toString() ?? saleUser?['avatarPath']?.toString() ?? '';
    final avatarUrl = avatarPath.isNotEmpty 
        ? Supabase.instance.client.storage.from('user_avatars').getPublicUrl(avatarPath)
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainerLow,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        (saleUser?['full_name'] ?? 'S')[0].toUpperCase(),
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhân viên phụ trách',
                  style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        saleUser?['full_name'] ?? 'Chưa phân công',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (info.assignment != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          'Chính thức',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
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
    final Color themeColor = isCompleted ? AppColors.statusActiveText : AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.white, size: 18)
                    : Text(
                        '$index',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.statusActiveText.withOpacity(0.5) : AppColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.level1,
                border: isCompleted ? Border.all(color: AppColors.statusActiveText.withOpacity(0.3), width: 1) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: isCompleted ? AppColors.statusActiveText : AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (distance > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.navigation_outlined, size: 12, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                distance >= 1000
                                    ? 'Cách ${(distance / 1000).toStringAsFixed(1)} km'
                                    : 'Cách ${distance.toStringAsFixed(0)} m',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.secondary,
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
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.statusActiveText.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.statusActiveText, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Hoàn thành',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.statusActiveText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isSaleRole && onCheckinPressed != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        minimumSize: const Size(80, AppSpacing.touchTarget),
                      ),
                      onPressed: onCheckinPressed,
                      icon: const Icon(Icons.login_rounded, size: 14),
                      label: Text(
                        'Check-in',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
