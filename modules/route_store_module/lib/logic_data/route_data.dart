import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entity/route_entity.dart';
import '../entity/route_detail_entity.dart';

final routeDataProvider = Provider<RouteData>((ref) => RouteData());

class RouteData {
  final SupabaseClient supabase = Supabase.instance.client;

  // ==================== ROUTE CRUD ====================

  /// Lấy danh sách tuyến đường (chỉ chưa bị ẩn)
  Future<List<RouteEntity>> getRoutes() async {
    final response = await supabase
        .from('routes')
        .select()
        .eq('is_hidden', false)
        .order('id', ascending: true);
    return (response as List).map((e) => RouteEntity.fromJson(e)).toList();
  }

  /// Lấy tuyến theo manager (created_by)
  Future<List<RouteEntity>> getRoutesByManager(String managerId) async {
    final response = await supabase
        .from('routes')
        .select()
        .eq('created_by', managerId)
        .eq('is_hidden', false)
        .order('id', ascending: true);
    return (response as List).map((e) => RouteEntity.fromJson(e)).toList();
  }

  /// Tạo tuyến mới
  Future<RouteEntity> createRoute(String routeName, String createdBy) async {
    final response = await supabase.from('routes').insert({
      'route_name': routeName,
      'created_by': createdBy,
      'is_hidden': false,
    }).select().single();
    return RouteEntity.fromJson(response);
  }

  /// Cập nhật tên tuyến
  Future<void> updateRouteName(int routeId, String newName) async {
    await supabase
        .from('routes')
        .update({'route_name': newName})
        .eq('id', routeId);
  }

  /// Ẩn tuyến (soft delete - KHÔNG xóa cứng theo instructions.md)
  Future<void> hideRoute(int routeId) async {
    await supabase
        .from('routes')
        .update({'is_hidden': true})
        .eq('id', routeId);
  }

  /// Hiện lại tuyến đã ẩn
  Future<void> unhideRoute(int routeId) async {
    await supabase
        .from('routes')
        .update({'is_hidden': false})
        .eq('id', routeId);
  }

  // ==================== ROUTE DETAILS ====================

  /// Lấy chi tiết cửa hàng trong tuyến (theo thứ tự sequence)
  Future<List<RouteDetailEntity>> getRouteDetails(int routeId) async {
    final response = await supabase
        .from('route_details')
        .select()
        .eq('route_id', routeId)
        .order('sequence', ascending: true);
    return (response as List)
        .map((e) => RouteDetailEntity.fromJson(e))
        .toList();
  }

  /// Thêm danh sách cửa hàng vào tuyến
  Future<void> addStoresToRoute(
      int routeId, List<RouteDetailEntity> details) async {
    final list = details.map((e) {
      return {
        'route_id': routeId,
        'store_id': e.storeId,
        'sequence': e.sequence,
      };
    }).toList();
    await supabase.from('route_details').insert(list);
  }

  /// Cập nhật chi tiết tuyến (xóa toàn bộ rồi thêm lại)
  Future<void> updateRouteDetails(
      int routeId, List<RouteDetailEntity> newDetails) async {
    await supabase.from('route_details').delete().eq('route_id', routeId);
    await addStoresToRoute(routeId, newDetails);
  }

  /// Cập nhật sort_order (sequence) cho drag-drop
  Future<void> updateSortOrder(
      int routeId, List<Map<String, int>> sortOrders) async {
    // sortOrders: [{'store_id': 1, 'sequence': 1}, {'store_id': 2, 'sequence': 2}, ...]
    for (final item in sortOrders) {
      await supabase
          .from('route_details')
          .update({'sequence': item['sequence']})
          .eq('route_id', routeId)
          .eq('store_id', item['store_id']!);
    }
  }

  /// Xóa 1 cửa hàng khỏi tuyến
  Future<void> removeStoreFromRoute(int routeId, int storeId) async {
    await supabase
        .from('route_details')
        .delete()
        .eq('route_id', routeId)
        .eq('store_id', storeId);
  }

  // ==================== REALTIME ====================

  /// Stream realtime cho bảng Routes
  Stream<List<RouteEntity>> streamRoutes() {
    return supabase
        .from('routes')
        .stream(primaryKey: ['id'])
        .eq('is_hidden', false)
        .order('id', ascending: true)
        .map((list) => list.map((e) => RouteEntity.fromJson(e)).toList());
  }

  /// Stream realtime cho chi tiết tuyến
  Stream<List<RouteDetailEntity>> streamRouteDetails(int routeId) {
    return supabase
        .from('route_details')
        .stream(primaryKey: ['id'])
        .eq('route_id', routeId)
        .order('sequence', ascending: true)
        .map((list) => list.map((e) => RouteDetailEntity.fromJson(e)).toList());
  }
}
