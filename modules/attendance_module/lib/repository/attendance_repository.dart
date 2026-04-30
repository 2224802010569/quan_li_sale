import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../entity/attendance.dart';
import '../entity/store.dart';
import '../entity/user.dart';
import '../logic_uc/attendance_uc.dart'; // Just ensuring imports are clean
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:core/storage/app_storage.dart';

class AttendanceRepository {
  SupabaseClient get _client => get<SupabaseConnect>().client!;

  /// Lấy thông tin người dùng hiện tại bao gồm cả Role
  Future<User> getCurrentUser() async {
    final stored = get<AppStorage>().get<Map<String, dynamic>>('user');
    if (stored == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }
    final userId = stored['id'] as String;
    final response = await _client.from('users').select('id, full_name, phone, password, role, employee_code, last_updated, group_id').eq('id', userId).single();
    return User.fromMap(response);
  }

  /// Lấy lịch sử chấm công
  /// Nếu là Manager: Lấy tất cả hoặc theo userId được chọn
  /// Nếu là Sale: Chỉ lấy của chính mình
  Future<List<Attendance>> getAttendanceHistory({String? userId, String? groupId, DateTime? month}) async {
    var query = _client
        .from('attendance')
        .select('*, stores(store_name), routes(route_name), users!inner(group_id)');

    if (userId != null) {
      query = query.eq('user_id', userId);
    } else if (groupId != null) {
      query = query.eq('users.group_id', groupId);
    }

    if (month != null) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);
      query = query
          .gte('checkin_time', start.toIso8601String())
          .lt('checkin_time', end.toIso8601String());
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Attendance.fromMap(e)).toList();
  }

  /// Lấy danh sách cửa hàng dựa trên Tuyến (Route) được giao cho Sale trong ngày hôm nay
  /// Logic: users -> assignments -> routes -> route_details -> stores
  Future<List<Store>> getAssignedStores(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Query join các bảng để lấy danh sách cửa hàng theo tuyến được giao
    final response = await _client
        .from('assignments')
        .select('''
          route_id,
          routes (
            route_name,
            route_details (
              stores (*)
            )
          )
        ''')
        .eq('user_id', userId)
        .eq('assigned_date', today);

    List<Store> assignedStores = [];

    if (response != null && (response as List).isNotEmpty) {
      for (var assignment in response) {
        final route = assignment['routes'];
        if (route != null && route['route_details'] != null) {
          final details = route['route_details'] as List;
          for (var item in details) {
            if (item['stores'] != null) {
              // Gán thêm thông tin route_name vào map của store để hiển thị
              final storeMap = Map<String, dynamic>.from(item['stores']);
              storeMap['route'] = route['route_name']; 
              storeMap['route_id'] = assignment['route_id'];
              assignedStores.add(Store.fromMap(storeMap));
            }
          }
        }
      }
    }
    return assignedStores;
  }

  /// Dành cho Manager: Lấy toàn bộ cửa hàng trong hệ thống
  Future<List<Store>> getAllStores() async {
    final response = await _client
        .from('stores')
        .select('*, route_details(routes(route_name))');
    return (response as List).map((e) => Store.fromMap(e)).toList();
  }

  /// Kiểm tra những store hệ thống Sale đã check-out trong ngày hôm nay
  Future<List<int>> getCompletedStoresForToday(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final response = await _client
        .from('attendance')
        .select('store_id')
        .eq('user_id', userId)
        .gte('created_at', startOfDay)
        .not('checkout_time', 'is', null);

    if (response != null) {
      return (response as List).map((e) => e['store_id'] as int).toList();
    }
    return [];
  }

  /// Kiểm tra xem Sale đã check-in tại cửa hàng này trong ngày chưa mà chưa check-out
  Future<bool> hasOngoingCheckIn(String userId, int storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final response = await _client
        .from('attendance')
        .select('id')
        .eq('user_id', userId)
        .eq('store_id', storeId)
        .gte('created_at', startOfDay)
        .isFilter('checkout_time', null)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  /// Upload ảnh chấm công lên Storage
  Future<String> uploadImage(String imagePath) async {
    final file = File(imagePath);
    final fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'attendance_images/$fileName';

    await _client.storage.from('attendance_images').upload(path, file);
    return _client.storage.from('attendance_images').getPublicUrl(path);
  }

  /// Lưu thông tin Check-in
  Future<void> saveAttendance({
    required String userId,
    required int storeId,
    int? routeId,
    required String imageUrl,
  }) async {
    final map = {
      'user_id': userId,
      'store_id': storeId,
      if (routeId != null) 'route_id': routeId,
      'checkin_time': DateTime.now().toIso8601String(),
      'checkin_image': imageUrl,
      'status': 'Incomplete',
    };
    await _client.from('attendance').insert(map); 
  }

  /// Thực hiện Check-out
  Future<void> submitCheckOut({
    required String userId,
    required int storeId,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Update attendance checkout_time
    final map = {
      'checkout_time': now,
      'checkout_image': 'https://example.com/mock-checkout-image.jpg',
      'status': 'Completed',
    };
    await _client.from('attendance')
        .update(map)
        .eq('user_id', userId)
        .eq('store_id', storeId)
        .isFilter('checkout_time', null);
        
    // Update users.last_updated
    await _client.from('users')
        .update({'last_updated': now})
        .eq('id', userId);
  }

  /// Track if user has enough working days based on check-ins today
  Future<int> getCheckInCountForToday(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final response = await _client
        .from('attendance')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfDay);
        
    return (response as List).length;
  }

  Future<List<User>> getUsersByGroup(String groupId, String excludeUserId) async {
    final response = await _client.from('users')
        .select('id, full_name, phone, password, role, employee_code, last_updated, group_id')
        .eq('group_id', groupId)
        .neq('id', excludeUserId);
    return (response as List).map((e) => User.fromMap(e)).toList(); 
  }
}