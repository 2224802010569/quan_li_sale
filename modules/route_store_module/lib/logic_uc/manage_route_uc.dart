import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/route_detail_entity.dart';
import 'package:route_store_module/logic_data/route_data.dart';

final manageRouteUcProvider = Provider<ManageRouteUc>((ref) {
  return ManageRouteUc(ref.read(routeDataProvider));
});

// Provider quản lý state danh sách tuyến
final routeListProvider = FutureProvider<List<RouteEntity>>((ref) async {
  final uc = ref.read(manageRouteUcProvider);
  return await uc.fetchAllRoutes();
});

class ManageRouteUc {
  final RouteData _routeData;

  ManageRouteUc(this._routeData);

  /// Lấy danh sách tuyến đường (chưa bị ẩn)
  Future<List<RouteEntity>> fetchAllRoutes() async {
    return await _routeData.getRoutes();
  }

  /// Lấy tuyến theo manager
  Future<List<RouteEntity>> fetchRoutesByManager(String managerId) async {
    return await _routeData.getRoutesByManager(managerId);
  }

  /// Tạo tuyến mới với danh sách các cửa hàng (theo thứ tự sequence)
  Future<RouteEntity> createRouteWithStores(
    String routeName,
    String createdBy,
    List<int> storeIds,
  ) async {
    // 1. Tạo Route
    final route = await _routeData.createRoute(routeName, createdBy);

    // 2. Tạo Route Details
    List<RouteDetailEntity> details = [];
    for (int i = 0; i < storeIds.length; i++) {
      details.add(
        RouteDetailEntity(
          routeId: route.id,
          storeId: storeIds[i],
          sequence: i + 1,
        ),
      );
    }

    if (details.isNotEmpty) {
      await _routeData.addStoresToRoute(route.id, details);
    }

    return route;
  }

  /// Lấy danh sách chi tiết (cửa hàng) của 1 tuyến
  Future<List<RouteDetailEntity>> getRouteDetails(int routeId) async {
    return await _routeData.getRouteDetails(routeId);
  }

  /// Cập nhật tên tuyến
  Future<void> updateRouteName(int routeId, String newName) async {
    await _routeData.updateRouteName(routeId, newName);
  }

  /// Cập nhật tuyến (sửa danh sách cửa hàng)
  Future<void> updateRouteStores(int routeId, List<int> newStoreIds) async {
    List<RouteDetailEntity> details = [];
    for (int i = 0; i < newStoreIds.length; i++) {
      details.add(
        RouteDetailEntity(
          routeId: routeId,
          storeId: newStoreIds[i],
          sequence: i + 1,
        ),
      );
    }
    await _routeData.updateRouteDetails(routeId, details);
  }

  /// Cập nhật thứ tự sắp xếp (drag-drop sorting)
  Future<void> updateSortOrder(int routeId, List<int> orderedStoreIds) async {
    final sortOrders = <Map<String, int>>[];
    for (int i = 0; i < orderedStoreIds.length; i++) {
      sortOrders.add({'store_id': orderedStoreIds[i], 'sequence': i + 1});
    }
    await _routeData.updateSortOrder(routeId, sortOrders);
  }

  /// Xóa 1 cửa hàng khỏi tuyến
  Future<void> removeStoreFromRoute(int routeId, int storeId) async {
    await _routeData.removeStoreFromRoute(routeId, storeId);
  }

  /// Thêm 1 cửa hàng vào tuyến
  Future<void> addStoreToRoute(int routeId, int storeId, int sequence) async {
    await _routeData.addStoresToRoute(routeId, [
      RouteDetailEntity(routeId: routeId, storeId: storeId, sequence: sequence),
    ]);
  }

  /// Ẩn tuyến (soft delete - KHÔNG xóa cứng)
  Future<void> hideRoute(int routeId) async {
    await _routeData.hideRoute(routeId);
  }
}
