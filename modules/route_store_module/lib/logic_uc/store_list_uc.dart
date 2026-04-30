import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import '../logic_data/store_data.dart';
import '../entity/store_item.dart';

class StoreListUC {
  StoreData get _data => StoreData(get<SupabaseConnect>().client!);

  Future<List<StoreItem>> getStoresForToday(String userId) async {
    final routeIds = await _data.getAssignedRouteIds(userId);
    if (routeIds.isEmpty) return [];

    final details = await _data.getStoresByRouteIds(routeIds);
    final completedIds = await _data.getCompletedStoreIds(userId);

    final items = <StoreItem>[];

    for (final detail in details) {
      final storeMap = detail['stores'];
      if (storeMap == null) continue;

      final routeMap = detail['routes'];
      final storeId = storeMap['id'] as int;

      items.add(StoreItem(
        id: storeId,
        name: storeMap['store_name'] as String? ?? 'Cửa hàng #$storeId',
        routeId: detail['route_id'] as int,
        routeName: routeMap != null ? (routeMap['route_name'] as String? ?? '') : '',
        sequence: detail['sequence'] as int? ?? 0,
        latitude: storeMap['latitude'] != null
            ? double.tryParse(storeMap['latitude'].toString())
            : null,
        longitude: storeMap['longitude'] != null
            ? double.tryParse(storeMap['longitude'].toString())
            : null,
        isCompleted: completedIds.contains(storeId),
      ));
    }

    items.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.sequence.compareTo(b.sequence);
    });

    return items;
  }
}
