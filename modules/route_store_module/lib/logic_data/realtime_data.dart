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

/// Stream provider cho assignments của user hiện tại (realtime)
final realtimeUserAssignmentsProvider = StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) {
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
  return supabase.from('users').stream(primaryKey: ['id']).eq('role', 'sale').map((data) => List<Map<String, dynamic>>.from(data));
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

/// Provider kết hợp Routes, Assignments và Users cho Manager View
final routeListWithInfoProvider = Provider<AsyncValue<List<RouteWithInfo>>>((ref) {
  final routesAsync = ref.watch(realtimeRoutesProvider);
  final assignmentsAsync = ref.watch(realtimeAllAssignmentsProvider);
  final usersAsync = ref.watch(realtimeSaleUsersProvider);

  // Xử lý loading và error tập trung
  if (routesAsync.isLoading || assignmentsAsync.isLoading || usersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (routesAsync.hasError) return AsyncValue.error(routesAsync.error!, routesAsync.stackTrace!);
  if (assignmentsAsync.hasError) return AsyncValue.error(assignmentsAsync.error!, assignmentsAsync.stackTrace!);
  if (usersAsync.hasError) return AsyncValue.error(usersAsync.error!, usersAsync.stackTrace!);

  final routes = routesAsync.value ?? [];
  final assignments = assignmentsAsync.value ?? [];
  final users = usersAsync.value ?? [];

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

    // TODO: Calculate progress from visit logs
    return RouteWithInfo(
      route: route,
      assignment: hasAssignment ? assignment : null,
      saleUser: saleUser,
      progress: 0.8, // Mock progress
    );
  }).toList();

  return AsyncValue.data(result);
});
