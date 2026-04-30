import 'package:supabase_flutter/supabase_flutter.dart';

class StoreData {
  final SupabaseClient _client;
  StoreData(this._client);

  /// Bước 1: Lấy route_id được assign cho sale hôm nay
  Future<List<int>> getAssignedRouteIds(String userId) async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('assignments')
        .select('route_id')
        .eq('user_id', userId)
        .eq('assigned_date', dateStr);

    return (response as List)
        .map((e) => e['route_id'] as int)
        .where((id) => id != null)
        .toList();
  }

  /// Bước 2: Lấy stores thuộc các route đó qua route_details
  Future<List<Map<String, dynamic>>> getStoresByRouteIds(List<int> routeIds) async {
    if (routeIds.isEmpty) return [];

    final response = await _client
        .from('route_details')
        .select('route_id, sequence, stores(id, store_name, latitude, longitude), routes(id, route_name)')
        .inFilter('route_id', routeIds)
        .order('sequence', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Lấy store_id đã Completed hôm nay
  Future<List<int>> getCompletedStoreIds(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final response = await _client
        .from('attendance')
        .select('store_id')
        .eq('user_id', userId)
        .eq('status', 'Completed')
        .gte('created_at', startOfDay);

    return (response as List).map((e) => e['store_id'] as int).toList();
  }
}
