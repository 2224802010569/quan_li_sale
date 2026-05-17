import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_data/store_data.dart';

final manageStoreUcProvider = Provider<ManageStoreUc>((ref) {
  return ManageStoreUc(ref.read(storeDataProvider));
});

// Provider quản lý state danh sách cửa hàng cho view manager
final storeListProvider = FutureProvider<List<StoreEntity>>((ref) async {
  final uc = ref.read(manageStoreUcProvider);
  return await uc.getAllStores();
});

// Provider cho search kết quả
final storeSearchQueryProvider = StateProvider<String>((ref) => '');

final storeSearchResultsProvider = FutureProvider<List<StoreEntity>>((ref) async {
  final query = ref.watch(storeSearchQueryProvider);
  final uc = ref.read(manageStoreUcProvider);
  
  if (query.isEmpty) {
    return await uc.getAllStores();
  }
  return await uc.searchStores(query);
});

class ManageStoreUc {
  final StoreData _storeData;

  ManageStoreUc(this._storeData);

  /// Lấy tất cả cửa hàng (chưa bị ẩn)
  Future<List<StoreEntity>> getAllStores() async {
    return await _storeData.getAllStores();
  }

  /// Lấy cửa hàng theo manager
  Future<List<StoreEntity>> getStoresByManager(String managerId) async {
    return await _storeData.getStoresByManager(managerId);
  }

  /// Thêm cửa hàng mới
  Future<void> addStore(StoreEntity store) async {
    await _storeData.addStore(store);
  }

  /// Cập nhật cửa hàng
  Future<void> updateStore(int id, StoreEntity store) async {
    await _storeData.updateStore(id, store);
  }

  /// Ẩn cửa hàng (soft delete - KHÔNG xóa cứng)
  Future<void> hideStore(int id) async {
    await _storeData.hideStore(id);
  }

  /// Hiện lại cửa hàng đã ẩn
  Future<void> unhideStore(int id) async {
    await _storeData.unhideStore(id);
  }

  /// Tìm kiếm cửa hàng theo tên hoặc địa chỉ
  Future<List<StoreEntity>> searchStores(String query) async {
    return await _storeData.searchStores(query);
  }
}
