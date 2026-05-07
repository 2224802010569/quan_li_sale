import 'package:supabase_flutter/supabase_flutter.dart';

/// Data layer — query bảng `assignments`.
/// Dùng để kiểm tra tuyến bị ảnh hưởng khi nhân viên đăng ký nghỉ phép.
/// Không chứa rule nghiệp vụ — chỉ trả raw data từ Supabase.
class AssignmentData {
  final SupabaseClient _client;

  const AssignmentData(this._client);

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Lấy danh sách tuyến được gán cho nhân viên vào một ngày cụ thể.
  ///
  /// [userId] — UUID của nhân viên.
  /// [date]   — Ngày cần kiểm tra (chỉ dùng phần date, bỏ time).
  ///
  /// Trả về list Map chứa: route_id, is_support, assigned_date.
  /// `is_support`: 1=Chính, 2=Hỗ trợ, 3=Dự phòng.
  Future<List<Map<String, dynamic>>> getAssignmentsByUser(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;

      final response = await _client
          .from('assignments')
          .select('route_id, is_support, assigned_date')
          .eq('user_id', userId)
          .eq('assigned_date', dateStr);

      return (response as List<dynamic>)
          .map((row) => row as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception(
        'AssignmentData.getAssignmentsByUser: Không thể lấy tuyến của user $userId '
        'vào ngày ${date.toIso8601String().split('T').first}. Chi tiết: $e',
      );
    }
  }

  /// Lấy tất cả tuyến của nhân viên trong một khoảng ngày (khi nghỉ nhiều ngày).
  ///
  /// [userId]    — UUID của nhân viên.
  /// [startDate] — Ngày bắt đầu khoảng cần kiểm tra.
  /// [endDate]   — Ngày kết thúc khoảng cần kiểm tra.
  ///
  /// Kết quả sắp xếp theo assigned_date tăng dần.
  Future<List<Map<String, dynamic>>> getAssignmentsByUserInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _client
          .from('assignments')
          .select('route_id, is_support, assigned_date')
          .eq('user_id', userId)
          .gte('assigned_date', startStr)
          .lte('assigned_date', endStr)
          .order('assigned_date', ascending: true);

      return (response as List<dynamic>)
          .map((row) => row as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception(
        'AssignmentData.getAssignmentsByUserInRange: Không thể lấy tuyến của user $userId '
        'từ $startDate đến $endDate. Chi tiết: $e',
      );
    }
  }

  /// Kiểm tra nhân viên có phải người chính (is_support = 1) trên tuyến nào đó không.
  /// Dùng để cảnh báo khi người chính nghỉ mà chưa có người dự phòng.
  ///
  /// Trả về `true` nếu nhân viên là người chính (is_support = 1) trên ít nhất 1 tuyến.
  Future<bool> isPrimaryOnAnyRoute(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;

      final response = await _client
          .from('assignments')
          .select('route_id')
          .eq('user_id', userId)
          .eq('assigned_date', dateStr)
          .eq('is_support', 1);

      return (response as List<dynamic>).isNotEmpty;
    } catch (e) {
      throw Exception(
        'AssignmentData.isPrimaryOnAnyRoute: Không thể kiểm tra vai trò của user $userId '
        'vào ngày ${date.toIso8601String().split('T').first}. Chi tiết: $e',
      );
    }
  }
}
