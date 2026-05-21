import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_store_module/entity/assignment_entity.dart';

final assignmentDataProvider = Provider<AssignmentData>((ref) => AssignmentData());

class AssignmentData {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== QUERY ====================

  /// Lấy danh sách phân công của user trong ngày cụ thể (join với Routes)
  Future<List<AssignmentEntity>> getAssignmentsByUserAndDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    final response = await _supabase
        .from('assignments')
        .select('''
          *,
          routes:route_id (*)
        ''')
        .eq('user_id', userId)
        .eq('assigned_date', dateStr);

    return (response as List).map((e) => AssignmentEntity.fromMap(e)).toList();
  }

  /// Lấy danh sách phân công theo route_id (cho Manager xem ai được gán)
  Future<List<AssignmentEntity>> getAssignmentsByRoute(int routeId) async {
    final response = await _supabase
        .from('assignments')
        .select('''
          *,
          routes:route_id (*)
        ''')
        .eq('route_id', routeId)
        .order('assigned_date', ascending: false);

    return (response as List).map((e) => AssignmentEntity.fromMap(e)).toList();
  }

  /// Lấy tất cả phân công trong ngày cụ thể (cho Manager view)
  Future<List<AssignmentEntity>> getAssignmentsByDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    final response = await _supabase
        .from('assignments')
        .select('''
          *,
          routes:route_id (*)
        ''')
        .eq('assigned_date', dateStr);

    return (response as List).map((e) => AssignmentEntity.fromMap(e)).toList();
  }

  // ==================== VALIDATION ====================

  /// Kiểm tra xem user đã có assignment trùng lịch trong ngày chưa
  /// Trả về true nếu CÓ conflict
  Future<bool> checkConflict(String userId, DateTime date, {int? excludeAssignmentId}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    var query = _supabase
        .from('assignments')
        .select('id')
        .eq('user_id', userId)
        .eq('assigned_date', dateStr);

    // Loại trừ assignment hiện tại (khi update)
    if (excludeAssignmentId != null) {
      query = query.neq('id', excludeAssignmentId);
    }

    final response = await query;
    return (response as List).isNotEmpty;
  }

  // ==================== MUTATION ====================

  /// Tạo hoặc cập nhật phân công
  Future<AssignmentEntity> upsertAssignment(AssignmentEntity assignment) async {
    final map = assignment.toMap();
    if (map['id'] == 0) {
      map.remove('id'); // Để DB tự gen ID
    }
    final response = await _supabase
        .from('assignments')
        .upsert(map)
        .select()
        .single();
    
    return AssignmentEntity.fromMap(response);
  }

  /// Điều chuyển tuyến sang nhân viên khác (Reassignment / Hỗ trợ)
  Future<void> reassignRoute(int assignmentId, String newUserId) async {
    await _supabase
        .from('assignments')
        .update({
          'user_id': newUserId,
          'is_support': 2, // Đánh dấu là đi hỗ trợ
        })
        .eq('id', assignmentId);
  }

  /// Tạo assignment hỗ trợ mới (support assignment)
  Future<AssignmentEntity> createSupportAssignment({
    required String userId,
    required int routeId,
    required DateTime date,
  }) async {
    final response = await _supabase
        .from('assignments')
        .insert({
          'user_id': userId,
          'route_id': routeId,
          'assigned_date': date.toIso8601String().split('T')[0],
          'is_support': 2, // Hỗ trợ
        })
        .select()
        .single();
    
    return AssignmentEntity.fromMap(response);
  }

  /// Xóa phân công
  Future<void> deleteAssignment(int assignmentId) async {
    await _supabase
        .from('assignments')
        .delete()
        .eq('id', assignmentId);
  }

  // ==================== REALTIME ====================

  /// Stream realtime cho bảng Assignments (theo user)
  Stream<List<AssignmentEntity>> streamAssignmentsByUser(String userId) {
    return _supabase
        .from('assignments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('assigned_date', ascending: false)
        .map((list) => list.map((e) => AssignmentEntity.fromMap(e)).toList());
  }

  /// Stream realtime cho tất cả assignments (Manager view)
  Stream<List<AssignmentEntity>> streamAllAssignments() {
    return _supabase
        .from('assignments')
        .stream(primaryKey: ['id'])
        .order('assigned_date', ascending: false)
        .map((list) => list.map((e) => AssignmentEntity.fromMap(e)).toList());
  }
}
