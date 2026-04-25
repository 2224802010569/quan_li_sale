import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entity/order.dart';
import '../entity/order_item.dart';

class OrderData {
  final SupabaseClient _client;

  OrderData(this._client);

  Future<int> createOrder({
    required Order order,
    required List<OrderItem> items,
  }) async {
    final orderResponse = await _client
        .from('orders')
        .insert(order.toMap())
        .select('id')
        .single();

    final orderId = orderResponse['id'] as int;

    final itemMaps = items.map((item) {
      final map = item.toMap();
      map['order_id'] = orderId;
      return map;
    }).toList();

    await _client.from('order_items').insert(itemMaps);

    return orderId;
  }

  Future<String> uploadFile({
    required String filePath,
    required String bucket,
    required String folder,
  }) async {
    final file = File(filePath);
    final extension = filePath.split('.').last;
    final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = '$folder/$fileName';

    await _client.storage.from(bucket).upload(storagePath, file);
    return _client.storage.from(bucket).getPublicUrl(storagePath);
  }

  Future<void> updateOrderPdfLink({
    required int orderId,
    required String pdfLink,
  }) async {
    await _client
        .from('orders')
        .update({'pdf_link': pdfLink})
        .eq('id', orderId);
  }

  Future<List<Map<String, dynamic>>> getSalesInGroup(String groupId) async {
    final response = await _client
        .from('users')
        .select('id, full_name')
        .eq('role', 'Sale')
        .eq('group_id', groupId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getOrderHistory({
    int? storeId,
    String? userId,
    List<String>? teamUserIds,
    DateTime? month,
  }) async {
    var query = _client.from('orders').select('*, stores(store_name), order_items(*, products(product_name))');
    
    if (month != null) {
      final start = DateTime(month.year, month.month, 1).toIso8601String();
      final nextMonth = month.month == 12 ? 1 : month.month + 1;
      final nextYear = month.month == 12 ? month.year + 1 : month.year;
      final end = DateTime(nextYear, nextMonth, 1).toIso8601String();
      query = query.gte('created_at', start).lt('created_at', end);
    } else {
      final threeMonthsAgo = DateTime.now()
          .subtract(const Duration(days: 90))
          .toIso8601String();
      query = query.gte('created_at', threeMonthsAgo);
    }

    if (storeId != null) {
      query = query.eq('store_id', storeId);
    }

    if (userId != null) {
      query = query.eq('user_id', userId);
    } else if (teamUserIds != null && teamUserIds.isNotEmpty) {
      query = query.inFilter('user_id', teamUserIds);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

}
