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

  const DailyRouteView({Key? key, this.onRouteTap, this.onCheckin}) : super(key: key);

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
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) {
            _logToFile('Assignments Error: $err');
            return Center(child: Text('Lỗi: $err'));
          },
          data: (assignments) {
            _logToFile('Assignments count: ${assignments.length}');
            for (var a in assignments) {
              _logToFile(' - Assignment: id=${a.assignmentId}, routeId=${a.routeId}, date=${a.assignedDate}, isSupport=${a.isSupport}');
            }
            return routesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) {
                _logToFile('Routes Error: $err');
                return Center(child: Text('Lỗi tải tuyến: $err'));
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: 24),
                      _buildActiveRouteCard(context, activeRoute, activeAssignment, routeDetails, attendance),
                      const SizedBox(height: 32),
                      if (otherRoutes.isNotEmpty) ...[
                        const Text(
                          'Lộ trình khác & Hỗ trợ',
                          style: TextStyle(
                            color: Color(0xFF1A1B21),
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            .toList(),
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
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Hôm nay bạn không có lịch trình nào',
            style: TextStyle(color: Colors.grey, fontSize: 16),
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
              style: const TextStyle(color: Color(0xFF434652), fontSize: 14),
            ),
            const Text(
              'Lộ trình hôm nay',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: const Color(0xFFD9E2FF),
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person, color: Color(0xFF0D47A1))
              : null,
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
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          shadows: const [
            BoxShadow(
              color: Color(0x0F1A1B21),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.routeName,
                        style: const TextStyle(
                          color: Color(0xFF1A1B21),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '[$visitedStores/$totalStores] Cửa hàng đã hoàn thành',
                        style: const TextStyle(color: Color(0xFF434652), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D47A1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F3FB),
              color: const Color(0xFF0D47A1),
              minHeight: 12,
              borderRadius: const BorderRadius.all(Radius.circular(9999)),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3FB),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDBCD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.support, color: Color(0xFF853100)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.routeName,
                    style: const TextStyle(
                      color: Color(0xFF1A1B21),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'SUPPORT',
                    style: TextStyle(
                      color: Color(0xFF853100),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'HIỆU SUẤT', value: '85%'),
          _StatItem(label: 'ĐƠN HÀNG', value: '12'),
          _StatItem(label: 'DOANH THU', value: '4.5M'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
