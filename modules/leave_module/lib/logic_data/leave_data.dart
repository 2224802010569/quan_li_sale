import 'package:supabase_flutter/supabase_flutter.dart';

import '../entity/leave_request_entity.dart';
import '../entity/leave_status.dart';

/// Data layer — giao tiếp trực tiếp với bảng `leave_requests` trên Supabase.
/// Không chứa bất kỳ rule nghiệp vụ nào — chỉ trả raw data.
class LeaveData {
  final SupabaseClient _client;

  const LeaveData(this._client);

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Lấy tất cả đơn nghỉ phép của một nhân viên (theo userId).
  /// Kết quả sắp xếp từ mới nhất đến cũ nhất.
  Future<List<LeaveRequestEntity>> getLeavesByUser(String userId) async {
    try {
      final response = await _client
          .from('leave_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => LeaveRequestEntity.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('LeaveData.getLeavesByUser: Không thể lấy danh sách đơn của user $userId. Chi tiết: $e');
    }
  }

  /// Lấy tất cả đơn nghỉ phép của cả nhóm (Manager dùng — theo groupId).
  /// Join với bảng `users` để lọc theo group_id.
  /// Kết quả sắp xếp từ mới nhất đến cũ nhất.
  Future<List<LeaveRequestEntity>> getLeavesByGroup(String groupId) async {
    try {
      final response = await _client
          .from('leave_requests')
          .select('*, users!leave_requests_user_id_fkey!inner(group_id)')
          .eq('users.group_id', groupId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => LeaveRequestEntity.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('LeaveData.getLeavesByGroup: Không thể lấy danh sách đơn của group $groupId. Chi tiết: $e');
    }
  }

  /// Lấy các đơn đang ở trạng thái Pending trong nhóm (Manager duyệt).
  Future<List<LeaveRequestEntity>> getPendingLeavesByGroup(String groupId) async {
    try {
      final response = await _client
          .from('leave_requests')
          .select('*, users!leave_requests_user_id_fkey!inner(group_id)')
          .eq('users.group_id', groupId)
          .eq('status', LeaveStatus.pending.toDbString())
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => LeaveRequestEntity.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('LeaveData.getPendingLeavesByGroup: Không thể lấy đơn Pending của group $groupId. Chi tiết: $e');
    }
  }

  /// Lấy một đơn cụ thể theo id.
  Future<LeaveRequestEntity> getLeaveById(int id) async {
    try {
      final response = await _client
          .from('leave_requests')
          .select()
          .eq('id', id)
          .single();

      return LeaveRequestEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('LeaveData.getLeaveById: Không tìm thấy đơn id=$id. Chi tiết: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // WRITE
  // ---------------------------------------------------------------------------

  /// Tạo mới một đơn nghỉ phép (Sale nộp đơn).
  /// Không truyền `id` và `created_at` — để Supabase auto-generate.
  Future<void> insertLeave(LeaveRequestEntity leave) async {
    try {
      final payload = {
        'user_id': leave.userId,
        'start_date': leave.startDate.toIso8601String().split('T').first,
        'end_date': leave.endDate.toIso8601String().split('T').first,
        'reason': leave.reason,
        'status': LeaveStatus.pending.toDbString(), // Luôn là Pending khi tạo mới
        if (leave.data != null) 'data': leave.data,
      };

      await _client.from('leave_requests').insert(payload);
    } catch (e) {
      throw Exception('LeaveData.insertLeave: Không thể tạo đơn nghỉ phép. Chi tiết: $e');
    }
  }

  /// Cập nhật trạng thái đơn nghỉ phép (Manager duyệt / từ chối).
  /// [id] — ID của đơn cần cập nhật.
  /// [status] — Giá trị mới: 'Approved' hoặc 'Rejected'.
  /// [approvedBy] — UUID của Manager thực hiện thao tác.
  Future<void> updateLeaveStatus(
    int id,
    String status,
    String approvedBy,
  ) async {
    try {
      await _client.from('leave_requests').update({
        'status': status,
        'approved_by': approvedBy,
      }).eq('id', id);
    } catch (e) {
      throw Exception('LeaveData.updateLeaveStatus: Không thể cập nhật trạng thái đơn id=$id. Chi tiết: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // HISTORY / STATISTICS
  // ---------------------------------------------------------------------------

  /// Lấy lịch sử đơn nghỉ của một nhân viên trong một năm cụ thể.
  Future<List<LeaveRequestEntity>> getLeavesByUserAndYear(
    String userId,
    int year,
  ) async {
    try {
      final startOfYear = '$year-01-01';
      final endOfYear = '$year-12-31';

      final response = await _client
          .from('leave_requests')
          .select()
          .eq('user_id', userId)
          .gte('start_date', startOfYear)
          .lte('start_date', endOfYear)
          .order('start_date', ascending: true);

      return (response as List<dynamic>)
          .map((row) => LeaveRequestEntity.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('LeaveData.getLeavesByUserAndYear: Không thể lấy lịch sử năm $year của user $userId. Chi tiết: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // USERS / GROUP
  // ---------------------------------------------------------------------------

  /// Lấy danh sách nhân viên Sale trong một nhóm (Manager dùng để populate dropdown lịch sử).
  /// Trả về list [{id: String, name: String}] để LeaveHistoryViewNotifier dùng.
  Future<List<Map<String, dynamic>>> getUsersInGroup(String groupId) async {
    try {
      final response = await _client
          .from('users')
          .select('id, full_name')
          .eq('group_id', groupId)
          .eq('role', 'Sale');

      return (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return {
          'id': map['id'] as String,
          'name': (map['full_name'] as String?) ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('LeaveData.getUsersInGroup: Không thể lấy danh sách nhân viên trong group $groupId. Chi tiết: $e');
    }
  }
}