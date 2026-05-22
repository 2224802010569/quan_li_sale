import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kpi_module/entity/kpi_setting_entity.dart';

final kpiDataProvider = Provider<KpiData>((ref) {
  return KpiData(Supabase.instance.client);
});

class KpiData {
  final SupabaseClient _supabase;

  KpiData(this._supabase);

  // 1. Lưu/Cập nhật KPI (Upsert dựa trên user_id, month, year)
  // Trong DB nên thiết lập UNIQUE(user_id, month, year) để tránh trùng lặp
  Future<void> upsertKpiSetting(KpiSettingEntity setting) async {
    // Tìm xem đã có setting cho user này trong tháng/năm này chưa
    final existing = await _supabase
        .from('kpi_settings')
        .select('id')
        .eq('sale_id', setting.userId)
        .eq('month', setting.month)
        .eq('year', setting.year)
        .maybeSingle();

    if (existing != null) {
      // Update
      await _supabase
          .from('kpi_settings')
          .update({'target_amount': setting.targetRevenue})
          .eq('id', existing['id']);
    } else {
      // Insert
      final map = setting.toMap();
      map.remove('id'); // Tự tăng
      await _supabase.from('kpi_settings').insert(map);
    }
  }

  // 2. Lấy Kpi Setting của 1 User trong tháng
  Future<KpiSettingEntity?> getKpiSetting(String userId, int month, int year) async {
    final response = await _supabase
        .from('kpi_settings')
        .select()
        .eq('sale_id', userId)
        .eq('month', month)
        .eq('year', year)
        .maybeSingle();

    if (response == null) return null;
    return KpiSettingEntity.fromMap(response);
  }

  // 3. Lấy tất cả Kpi Settings trong tháng (dành cho Dashboard)
  Future<List<KpiSettingEntity>> getAllKpiSettings(int month, int year) async {
    final response = await _supabase
        .from('kpi_settings')
        .select()
        .eq('month', month)
        .eq('year', year);

    return List<Map<String, dynamic>>.from(response)
        .map((e) => KpiSettingEntity.fromMap(e))
        .toList();
  }

  // 4. Lấy danh sách nhân viên Sale trong cùng group của Manager
  Future<List<Map<String, dynamic>>> getSaleUsersByManager(String managerId) async {
    // Lấy group_id của manager
    final manager = await _supabase
        .from('users')
        .select('group_id')
        .eq('id', managerId)
        .maybeSingle();

    if (manager == null || manager['group_id'] == null) return [];

    // Lấy tất cả user có cùng group_id (có thể loại trừ chính manager nếu cần)
    final response = await _supabase
        .from('users')
        .select()
        .eq('group_id', manager['group_id'])
        .neq('id', managerId);
        
    return List<Map<String, dynamic>>.from(response);
  }

  // 5. Lấy các đơn hàng đã hoàn thành trong tháng
  Future<List<Map<String, dynamic>>> getCompletedOrders(String userId, int month, int year) async {
    // Xây dựng ngày bắt đầu và ngày kết thúc của tháng
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final response = await _supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String())
        .lt('created_at', endDate.toIso8601String());

    return List<Map<String, dynamic>>.from(response);
  }

  // 6. Lấy ảnh check-in từ bảng attendance
  Future<List<String>> getAttendancePhotoUrls(String userId, int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final response = await _supabase
        .from('attendance')
        .select('checkin_image')
        .eq('user_id', userId)
        .gte('checkin_time', startDate.toIso8601String())
        .lt('checkin_time', endDate.toIso8601String());

    List<String> urls = [];
    for (var row in response) {
      final path = row['checkin_image'] as String?;
      if (path != null && path.isNotEmpty) {
        final url = _supabase.storage.from('attendance_photos').getPublicUrl(path);
        urls.add(url);
      }
    }
    return urls;
  }

  // 7. Lấy public URL của avatar
  String getUserAvatarUrl(String avatarPath) {
    if (avatarPath.trim().isEmpty) return '';
    try {
      return _supabase.storage.from('user_avatars').getPublicUrl(avatarPath);
    } catch (_) {
      return '';
    }
  }
}
