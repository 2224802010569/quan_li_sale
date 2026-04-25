import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entity/product_entity.dart';
import '../entity/inventory_check_entity.dart';
import '../entity/inventory_detail_entity.dart';
import '../entity/display_entity.dart';

class InventoryDataService {
  final SupabaseClient _supabase;

  InventoryDataService(this._supabase);

  // Lấy danh sách toàn bộ sản phẩm
  Future<List<ProductEntity>> fetchAllProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select();

      return (data as List<dynamic>)
          .map((e) => ProductEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sản phẩm: $e');
    }
  }

  // Lấy số lượng tồn từ lần kiểm trước của cửa hàng
  Future<Map<String, int>> fetchLastCheckQuantities(String storeId) async {
    try {
      final storeIdInt = int.parse(storeId);
      final lastCheck = await _supabase
          .from('inventory_checks')
          .select('id')
          .eq('store_id', storeIdInt)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastCheck == null) {
        return {};
      }

      final checkId = lastCheck['id'] as int;
      final detailsData = await _supabase
          .from('inventory_details')
          .select('product_id, quantity')
          .eq('check_id', checkId);

      final Map<String, int> previousQuantities = {};
      for (var row in (detailsData as List<dynamic>)) {
        previousQuantities[row['product_id'].toString()] = row['quantity'] as int;
      }
      return previousQuantities;
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu kiểm tồn trước: $e');
    }
  }

  // Lưu dữ liệu kiểm tồn (gồm phiếu check và danh sách detail)
  Future<void> submitInventoryData(
      InventoryCheckEntity check, List<InventoryDetailEntity> details) async {
    try {
      // 1. Lưu vào inventory_checks VÀ LẤY VỀ ID VỪA ĐƯỢC TẠO
      var checkJson = check.toJson();
      checkJson.remove('id'); // Xóa id để DB tự sinh

      final checkResponse = await _supabase
          .from('inventory_checks')
          .insert(checkJson)
          .select()
          .single();

      final int newCheckId = checkResponse['id'];

      // 2. Cập nhật check_id cho toàn bộ chi tiết và lưu vào inventory_details
      if (details.isNotEmpty) {
        final detailsJson = details.map((d) {
          var json = d.toJson();
          json['check_id'] = newCheckId; // Gắn ID phiếu mẹ vào chi tiết (kiểu int)
          json.remove('id'); // Xóa id chi tiết để DB tự sinh
          return json;
        }).toList();

        await _supabase.from('inventory_details').insert(detailsJson);
      }
    } catch (e) {
      throw Exception('Lỗi khi lưu dữ liệu kiểm tồn: $e');
    }
  }

  // Upload ảnh minh chứng và lưu DB
  Future<void> uploadDisplayImage(DisplayEntity display, File imageFile) async {
    try {
      // Tạo đường dẫn upload (Dùng store_id thay vì display.id vì id lúc này đang null)
      final fileName = 'store_${display.storeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '${display.storeId}/$fileName';
      
      // Upload file lên bucket 'displays'
      await _supabase.storage.from('displays').upload(storagePath, imageFile);
      
      // Lấy public URL của ảnh vừa upload
      final publicUrl = _supabase.storage.from('displays').getPublicUrl(storagePath);
      
      // Tạo json để insert, bỏ qua id để DB tự sinh
      var insertData = display.toJson();
      insertData.remove('id');
      insertData['image_url'] = publicUrl;

      // Lưu thông tin hiển thị (ảnh) vào bảng displays
      await _supabase.from('displays').insert(insertData);
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh trưng bày: $e');
    }
  }
}