import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_store_module/entity/store_entity.dart';

final storeDataProvider = Provider<StoreData>((ref) => StoreData());

class StoreData {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy tất cả cửa hàng (chỉ lấy chưa bị ẩn)
  Future<List<StoreEntity>> getAllStores() async {
    final response = await _supabase
        .from('stores')
        .select()
        .eq('is_hidden', false)
        .order('id', ascending: true);
    return (response as List).map((e) => StoreEntity.fromMap(e)).toList();
  }

  /// Lấy cửa hàng theo manager_id (chỉ chưa bị ẩn)
  Future<List<StoreEntity>> getStoresByManager(String managerId) async {
    final response = await _supabase
        .from('stores')
        .select()
        .eq('manager_id', managerId)
        .eq('is_hidden', false)
        .order('id', ascending: true);
    return (response as List).map((e) => StoreEntity.fromMap(e)).toList();
  }

  /// Lấy cửa hàng theo ID
  Future<StoreEntity?> getStoreById(int id) async {
    final response = await _supabase
        .from('stores')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response != null) {
      return StoreEntity.fromMap(response);
    }
    return null;
  }

  /// Thêm cửa hàng mới
  Future<void> addStore(StoreEntity store) async {
    await _supabase.from('stores').insert(store.toMap());
  }

  /// Cập nhật cửa hàng
  Future<void> updateStore(int id, StoreEntity store) async {
    await _supabase.from('stores').update(store.toMap()).eq('id', id);
  }

  /// Ẩn cửa hàng (soft delete - KHÔNG xóa cứng theo instructions.md)
  Future<void> hideStore(int id) async {
    await _supabase
        .from('stores')
        .update({'is_hidden': true})
        .eq('id', id);
  }

  /// Hiện lại cửa hàng đã ẩn
  Future<void> unhideStore(int id) async {
    await _supabase
        .from('stores')
        .update({'is_hidden': false})
        .eq('id', id);
  }

  /// Tìm kiếm cửa hàng theo tên hoặc địa chỉ
  Future<List<StoreEntity>> searchStores(String query) async {
    final response = await _supabase
        .from('stores')
        .select()
        .eq('is_hidden', false)
        .or('store_name.ilike.%$query%,address.ilike.%$query%')
        .order('store_name', ascending: true);
    return (response as List).map((e) => StoreEntity.fromMap(e)).toList();
  }

  /// Stream realtime cho bảng stores
  Stream<List<StoreEntity>> streamStores() {
    return _supabase
        .from('stores')
        .stream(primaryKey: ['id'])
        .eq('is_hidden', false)
        .order('id', ascending: true)
        .map((list) => list.map((e) => StoreEntity.fromMap(e)).toList());
  }
}
