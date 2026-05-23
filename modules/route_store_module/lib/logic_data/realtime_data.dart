import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_data/store_data.dart';
import 'package:route_store_module/logic_data/route_data.dart';
import 'package:route_store_module/logic_data/assignment_data.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/entity/route_detail_entity.dart';

// ==================== REALTIME PROVIDERS ====================

/// Stream provider cho danh sách cửa hàng (realtime)
final realtimeStoresProvider = StreamProvider<List<StoreEntity>>((ref) {
  final storeData = ref.read(storeDataProvider);
  return storeData.streamStores();
});

/// Stream provider cho danh sách tuyến (realtime)
final realtimeRoutesProvider = StreamProvider<List<RouteEntity>>((ref) {
  final routeData = ref.read(routeDataProvider);
  return routeData.streamRoutes();
});


/// Stream provider cho chi tiết của một tuyến (realtime)
final realtimeRouteDetailsProvider = StreamProvider.family<List<RouteDetailEntity>, int>((ref, routeId) {
  final routeData = ref.read(routeDataProvider);
  return routeData.streamRouteDetails(routeId);
});

/// Stream provider cho tất cả chi tiết tuyến (tất cả các cửa hàng đã có tuyến)
final realtimeAllRouteDetailsProvider = StreamProvider<List<RouteDetailEntity>>((ref) {
  final routeData = ref.read(routeDataProvider);
  return routeData.supabase
      .from('route_details')
      .stream(primaryKey: ['id'])
      .map((list) => list.map((e) => RouteDetailEntity.fromJson(e)).toList());
});

/// Stream provider cho assignments của user hiện tại (realtime)
final realtimeUserAssignmentsProvider = StreamProvider.autoDispose.family<List<AssignmentEntity>, String>((ref, userId) {
  ref.keepAlive();
  if (userId.isEmpty) return Stream.value([]);
  final assignmentData = ref.read(assignmentDataProvider);
  return assignmentData.streamAssignmentsByUser(userId);
});

/// Stream provider cho tất cả assignments (Manager realtime)
final realtimeAllAssignmentsProvider = StreamProvider<List<AssignmentEntity>>((ref) {
  final assignmentData = ref.read(assignmentDataProvider);
  return assignmentData.streamAllAssignments();
});

/// Stream provider cho danh sách users (Sale)
final realtimeSaleUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.read(routeDataProvider).supabase;
  return supabase.from('users').stream(primaryKey: ['id']).map((data) {
    return List<Map<String, dynamic>>.from(data)
        .where((u) => u['role']?.toString().toLowerCase() == 'sale')
        .toList();
  });
});


/// Model cho Route Card UI
class RouteWithInfo {
  final RouteEntity route;
  final AssignmentEntity? assignment;
  final Map<String, dynamic>? saleUser;
  final double progress; // 0.0 to 1.0

  RouteWithInfo({
    required this.route,
    this.assignment,
    this.saleUser,
    this.progress = 0.0,
  });
}

/// Stream provider cho attendance trong tuần
final realtimeAttendanceThisWeekProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.read(routeDataProvider).supabase;
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  
  return supabase
      .from('attendance')
      .stream(primaryKey: ['id'])
      .gte('checkin_time', startOfWeek.toIso8601String());
});



/// Provider kết hợp Routes, Assignments và Users cho Manager View
final routeListWithInfoProvider = Provider<AsyncValue<List<RouteWithInfo>>>((ref) {
  final routesAsync = ref.watch(realtimeRoutesProvider);
  final assignmentsAsync = ref.watch(realtimeAllAssignmentsProvider);
  final usersAsync = ref.watch(realtimeSaleUsersProvider);
  final attendanceAsync = ref.watch(realtimeAttendanceThisWeekProvider);
  final routeDetailsAsync = ref.watch(realtimeAllRouteDetailsProvider);

  // Xử lý loading và error tập trung
  if (routesAsync.isLoading || assignmentsAsync.isLoading || usersAsync.isLoading || attendanceAsync.isLoading || routeDetailsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (routesAsync.hasError) return AsyncValue.error(routesAsync.error!, routesAsync.stackTrace!);
  if (assignmentsAsync.hasError) return AsyncValue.error(assignmentsAsync.error!, assignmentsAsync.stackTrace!);
  if (usersAsync.hasError) return AsyncValue.error(usersAsync.error!, usersAsync.stackTrace!);
  if (attendanceAsync.hasError) return AsyncValue.error(attendanceAsync.error!, attendanceAsync.stackTrace!);
  if (routeDetailsAsync.hasError) return AsyncValue.error(routeDetailsAsync.error!, routeDetailsAsync.stackTrace!);

  final routes = routesAsync.value ?? [];
  final assignments = assignmentsAsync.value ?? [];
  final users = usersAsync.value ?? [];
  final attendance = attendanceAsync.value ?? [];
  final routeDetails = routeDetailsAsync.value ?? [];

  final result = routes.map((route) {
    // Tìm assignment cho route này (giả sử 1 route chỉ có 1 active assignment tại 1 thời điểm)
    final assignment = assignments.firstWhere(
      (a) => a.routeId == route.id,
      orElse: () => AssignmentEntity(
        assignmentId: 0,
        userId: '',
        routeId: 0,
        assignedDate: DateTime.now(),
        isSupport: 1,
      ),
    );

    final hasAssignment = assignment.assignmentId != 0;
    final saleUser = hasAssignment
        ? users.firstWhere((u) => u['id'].toString() == assignment.userId, orElse: () => {})
        : null;

    // Calculate progress
    final storesInRoute = routeDetails.where((rd) => rd.routeId == route.id).map((rd) => rd.storeId).toSet();
    final totalStores = storesInRoute.length;
    
    double progress = 0.0;
    if (totalStores > 0) {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final visitedStores = storesInRoute.where((storeId) =>
        attendance.any((a) {
          final checkinStr = a['checkin_time']?.toString() ?? '';
          final checkoutStr = a['checkout_time']?.toString() ?? '';
          final isToday = checkinStr.startsWith(todayStr);
          return a['store_id'] == storeId
              && isToday
              && checkinStr.isNotEmpty
              && checkoutStr.isNotEmpty;
        })
      ).length;
      progress = visitedStores / totalStores;
    }

    return RouteWithInfo(
      route: route,
      assignment: hasAssignment ? assignment : null,
      saleUser: saleUser,
      progress: progress,
    );
  }).toList();

  return AsyncValue.data(result);
});
