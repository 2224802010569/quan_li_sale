import 'package:supabase_flutter/supabase_flutter.dart';
import '../entity/product.dart';

class ProductData {
  final SupabaseClient _client;

  ProductData(this._client);

  Future<List<Product>> getProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('product_name', ascending: true);

    return (response as List).map((e) => Product.fromMap(e)).toList();
  }
}
