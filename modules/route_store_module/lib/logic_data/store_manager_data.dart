import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:route_store_module/entity/store_entity.dart';

class StoreManagerData {
  final supabase = get<SupabaseConnect>().client!;

  Future<List<StoreEntity>> getStores() async {
    final response = await supabase
        .from('stores')
        .select()
        .order('id', ascending: true);

    return (response as List).map((e) => StoreEntity.fromMap(e)).toList();
  }

  Future<void> createStore(StoreEntity store) async {
    await supabase.from('stores').insert(store.toMap());
  }

  Future<void> updateStore(StoreEntity store) async {
    await supabase.from('stores').update(store.toMap()).eq('id', store.id!);
  }

  Future<void> deleteStore(int storeId) async {
    await supabase.from('stores').delete().eq('id', storeId);
  }
}
