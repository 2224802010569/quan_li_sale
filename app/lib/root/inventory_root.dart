import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:core/di/supabase.dart';
import 'package:inventory_module/inventory_module.dart';
import 'package:inventory_module/input/inventory_input.dart';
import 'package:flutter/material.dart';

class InventoryRoot {
  Widget build(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user')!;
    final storeId = storage.get<int>('current_store_id') ?? 0;

    return FutureBuilder<List<int>>(
      future: _fetchProductIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final input = InventoryInput(
          userId: user['id'],
          storeId: storeId.toString(),
          productIds: snapshot.data!,
        );

        return InventoryModule(
          input: input,
          onOutput: (output) {
            if (output.success && output.actualStocks != null) {
              // Lưu data vào storage để INVENTORY_SUMMARY đọc
              storage.set('inventory_actual', output.actualStocks);
              storage.set('inventory_previous', output.previousStocks);
              storage.set('inventory_products', output.products);
              onNavigate(AppOutput(toModule: 'INVENTORY_SUMMARY'));
            } else if (output.success) {
              onNavigate(AppOutput(toModule: 'STORE_HOME'));
            }
          },
          onBack: () => onNavigate(AppOutput(toModule: 'STORE_HOME')),
        );
      },
    );
  }

  /// Fetch danh sách product IDs từ Supabase.
  /// TODO: Nếu cần lọc theo tuyến (route_id), thay query thành join qua
  /// order_items hoặc bảng mapping product-route tương ứng.
  Future<List<int>> _fetchProductIds() async {
    try {
      final supabase = get<SupabaseConnect>().client!;
      final res = await supabase.from('products').select('id');
      return (res as List).map((e) => int.parse(e['id'].toString())).toList();
    } catch (e) {
      return [];
    }
  }
}
