import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/entity/route_detail_entity.dart';
import 'package:route_store_module/view/manager/route_detail_view.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:core/theme/theme.dart';

void _logToFile(String msg) {
  try {
    final file = File('c:/Users/Admin/Documents/GitHub/quan_li_sale/app/doc/app_debug_log.txt');
    file.writeAsStringSync('${DateTime.now().toIso8601String()} - $msg\n', mode: FileMode.append);
  } catch (_) {}
}

class DailyRouteView extends ConsumerWidget {
  /// Callback khi người dùng chọn một route để xem danh sách cửa hàng.
  /// Nếu null, widget sẽ dùng Navigator.push nội bộ (mặc định).
  final void Function(RouteEntity route, AssignmentEntity assignment)? onRouteTap;
  final void Function(StoreEntity store, RouteEntity route)? onCheckin;

  const DailyRouteView({super.key, this.onRouteTap, this.onCheckin});

  void _handleRouteTap(BuildContext context, RouteEntity route, AssignmentEntity assignment) {
    if (onRouteTap != null) {
      onRouteTap!(route, assignment);
    } else {
      // Fallback: navigate nội bộ → xem danh sách cửa hàng trong tuyến
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RouteDetailView(route: route, onCheckin: onCheckin),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user');
    final userId = user?['id'] ?? '';
    final assignmentsAsync = ref.watch(realtimeUserAssignmentsProvider(userId));
    final routesAsync = ref.watch(realtimeRoutesProvider);
    final routeDetailsAsync = ref.watch(realtimeAllRouteDetailsProvider);
    final attendanceAsync = ref.watch(realtimeAttendanceThisWeekProvider);

    final routeDetails = routeDetailsAsync.value ?? <RouteDetailEntity>[];
    final attendance = attendanceAsync.value ?? <Map<String, dynamic>>[];

    _logToFile('=== DailyRouteView Build ===');
    _logToFile('userId: $userId, name: ${user?['full_name']}, role: ${user?['role']}');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
          error: (err, _) {
            _logToFile('Assignments Error: $err');
            return Center(child: Text('Lỗi: $err', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)));
          },
          data: (assignments) {
            _logToFile('Assignments count: ${assignments.length}');
            for (var a in assignments) {
              _logToFile(' - Assignment: id=${a.assignmentId}, routeId=${a.routeId}, date=${a.assignedDate}, isSupport=${a.isSupport}');
            }
            return routesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              error: (err, _) {
                _logToFile('Routes Error: $err');
                return Center(child: Text('Lỗi tải tuyến: $err', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)));
              },
              data: (routes) {
                _logToFile('Routes count: ${routes.length}');
                
                final todayStr = DateTime.now().toIso8601String().split('T')[0];
                final todayAssignments = assignments.where((a) => a.assignedDate.toIso8601String().split('T')[0] == todayStr).toList();
                
                _logToFile('todayStr: $todayStr');
                _logToFile('todayAssignments count: ${todayAssignments.length}');
                for (var ta in todayAssignments) {
                  _logToFile(' - Today Assignment: routeId=${ta.routeId}');
                }
                
                final assignedRoutes = routes
                    .where((r) => todayAssignments.any((a) => a.routeId == r.id))
                    .toList();
                
                _logToFile('assignedRoutes count: ${assignedRoutes.length}');
                for (var ar in assignedRoutes) {
                  _logToFile(' - Assigned Route: id=${ar.id}, name=${ar.routeName}');
                }

                if (assignedRoutes.isEmpty) {
                  return _buildEmptyState();
                }

                // Assume the first one is the active one for simplicity in this mockup
                final activeRoute = assignedRoutes.first;
                final activeAssignment = assignments.firstWhere(
                  (a) => a.routeId == activeRoute.id,
                  orElse: () => AssignmentEntity(
                    assignmentId: 0,
                    userId: userId,
                    routeId: activeRoute.id,
                    isSupport: 1,
                    assignedDate: DateTime.now(),
                  ),
                );
                final otherRoutes = assignedRoutes.skip(1).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildActiveRouteCard(context, activeRoute, activeAssignment, routeDetails, attendance),
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildRouteMap(context),
                      if (otherRoutes.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          'Lộ trình khác & Hỗ trợ',
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ...otherRoutes
                            .map((r) {
                              final assignment = assignments.firstWhere(
                                (a) => a.routeId == r.id,
                                orElse: () => AssignmentEntity(
                                  assignmentId: 0,
                                  userId: userId,
                                  routeId: r.id,
                                  isSupport: 2,
                                  assignedDate: DateTime.now(),
                                ),
                              );
                              return _buildOtherRouteCard(context, r, assignment);
                            })
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Hôm nay bạn không có lịch trình nào',
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? user) {
    final name = user?['fullName'] ?? user?['full_name'] ?? 'Sale';
    final avatarPath = user?['avatar_path']?.toString() ?? user?['avatarPath']?.toString() ?? '';
    final avatarUrl = avatarPath.isNotEmpty 
        ? Supabase.instance.client.storage.from('user_avatars').getPublicUrl(avatarPath)
        : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào buổi sáng, $name',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              'Lộ trình hôm nay',
              style: AppTextStyles.headlineLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.online, width: 2),
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                      )
                    : const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveRouteCard(
    BuildContext context,
    RouteEntity route,
    AssignmentEntity assignment,
    List<RouteDetailEntity> routeDetails,
    List<Map<String, dynamic>> attendance,
  ) {
    // Tính toán tiến độ shop hoàn thành trong tuyến
    final storesInRoute = routeDetails.where((rd) => rd.routeId == route.id).map((rd) => rd.storeId).toSet();
    final totalStores = storesInRoute.length;
    
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final visitedStores = storesInRoute.where((storeId) => 
      attendance.any((a) {
        final checkin = a['checkin_time']?.toString() ?? '';
        final checkout = a['checkout_time']?.toString() ?? '';
        final isToday = checkin.startsWith(todayStr);
        return a['store_id'] == storeId && isToday && checkin.isNotEmpty && checkout.isNotEmpty;
      })
    ).length;

    final double progress = totalStores > 0 ? visitedStores / totalStores : 0.0;

    return GestureDetector(
      onTap: () => _handleRouteTap(context, route, assignment),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'ĐANG DIỄN RA',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 28),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              route.routeName,
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '[$visitedStores/$totalStores] Cửa hàng đã hoàn thành',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiến độ',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: AppColors.secondary,
              minHeight: 6,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherRouteCard(BuildContext context, RouteEntity route, AssignmentEntity assignment) {
    return GestureDetector(
      onTap: () => _handleRouteTap(context, route, assignment),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.stackGap),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.support_agent_outlined, color: AppColors.secondary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.routeName,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      'SUPPORT',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteMap(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bản đồ lộ trình',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Có thể mở một trang bản đồ chi tiết
              },
              child: Text(
                'Chi tiết',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.level1,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: CustomPaint(
              painter: MockMapPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()..color = const Color(0xFFEFF4FF);
    canvas.drawRect(Offset.zero & size, paintBg);

    // Vẽ lưới đường phố mờ mờ
    final paintGrid = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }

    // Vẽ đường lộ trình (Route line)
    final routePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(30, size.height - 30)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width - 40, size.height * 0.5);

    canvas.drawPath(path, routePaint);

    // Vẽ các Waypoint dots
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = [
      Offset(30, size.height - 30),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width - 40, size.height * 0.5),
    ];

    for (var pt in points) {
      canvas.drawCircle(pt, 6, dotPaint);
      canvas.drawCircle(pt, 6, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
