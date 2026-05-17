import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_data/store_data.dart';

final searchStoreUcProvider = Provider<SearchStoreUc>((ref) {
  return SearchStoreUc(ref.read(storeDataProvider));
});

/// Provider cho search query (debounce nên được handle ở UI)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider cho kết quả search
final searchResultsProvider = FutureProvider<List<StoreEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final uc = ref.read(searchStoreUcProvider);

  if (query.trim().isEmpty) {
    return [];
  }
  return await uc.search(query.trim());
});

class SearchStoreUc {
  final StoreData _storeData;

  SearchStoreUc(this._storeData);

  /// Tìm kiếm cửa hàng theo tên hoặc địa chỉ
  Future<List<StoreEntity>> search(String query) async {
    return await _storeData.searchStores(query);
  }
}
