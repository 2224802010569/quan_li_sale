import 'package:supabase_flutter/supabase_flutter.dart';

import '../entity/leave_request_entity.dart';
import '../entity/leave_status.dart';
import '../logic_data/leave_data.dart';

/// Use-case: Manager duyệt hoặc từ chối đơn nghỉ phép.
///
/// Trách nhiệm:
///   1. Fetch đơn theo [leaveId] để lấy thông tin user_id.
///   2. Validate quyền: user_id của đơn phải thuộc [groupId] của Manager.
///   3. Validate trạng thái: chỉ duyệt được đơn đang ở `Pending`.
///   4. Validate [decision]: chỉ nhận 'Approved' hoặc 'Rejected'.
///   5. Gọi [LeaveData.updateLeaveStatus] để cập nhật DB.
///
/// Throw [Exception] tiếng Việt nếu vi phạm rule.
class ApproveLeaveUc {
  final LeaveData _leaveData;
  final SupabaseClient _client;

  const ApproveLeaveUc(this._leaveData, this._client);

  /// Duyệt hoặc từ chối đơn nghỉ phép.
  ///
  /// [leaveId]    — ID của đơn cần xử lý.
  /// [decision]   — Quyết định: `'Approved'` hoặc `'Rejected'`.
  /// [approverId] — UUID của Manager thực hiện thao tác.
  /// [groupId]    — group_id của Manager (để validate quyền).
  ///
  /// Trả về [LeaveRequestEntity] đã được cập nhật.
  Future<LeaveRequestEntity> call({
    required int leaveId,
    required String decision,
    required String approverId,
    required String groupId,
  }) async {
    // -------------------------------------------------------------------------
    // Bước 1: Validate decision
    // -------------------------------------------------------------------------
    _validateDecision(decision);

    // -------------------------------------------------------------------------
    // Bước 2: Fetch đơn từ DB
    // -------------------------------------------------------------------------
    final leave = await _leaveData.getLeaveById(leaveId);

    // -------------------------------------------------------------------------
    // Bước 3: Validate trạng thái — chỉ duyệt được đơn Pending
    // -------------------------------------------------------------------------
    if (leave.status != LeaveStatus.pending) {
      throw Exception(
        'Không thể thay đổi trạng thái: đơn này đã được xử lý '
        '(${leave.status.label}). Chỉ có thể duyệt đơn đang ở trạng thái "Đang chờ".',
      );
    }

    // -------------------------------------------------------------------------
    // Bước 4: Validate quyền — user_id của đơn phải thuộc group của Manager
    // -------------------------------------------------------------------------
    await _validateManagerPermission(
      userId: leave.userId,
      managerGroupId: groupId,
      leaveId: leaveId,
    );

    // -------------------------------------------------------------------------
    // Bước 5: Cập nhật trạng thái vào DB
    // -------------------------------------------------------------------------
    await _leaveData.updateLeaveStatus(leaveId, decision, approverId);

    // -------------------------------------------------------------------------
    // Bước 6: Trả về entity đã được cập nhật
    // -------------------------------------------------------------------------
    return await _leaveData.getLeaveById(leaveId);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Validate quyết định của Manager.
  void _validateDecision(String decision) {
    final valid = {'Approved', 'Rejected'};
    if (!valid.contains(decision)) {
      throw Exception(
        'Quyết định không hợp lệ: "$decision". '
        'Chỉ chấp nhận "Approved" hoặc "Rejected".',
      );
    }
  }

  /// Kiểm tra [userId] của đơn có thuộc [managerGroupId] không.
  /// Query bảng `users` để lấy group_id của nhân viên.
  Future<void> _validateManagerPermission({
    required String userId,
    required String managerGroupId,
    required int leaveId,
  }) async {
    try {
      final response = await _client
          .from('users')
          .select('group_id')
          .eq('id', userId)
          .single();

      final userGroupId = response['group_id'] as String?;

      if (userGroupId == null || userGroupId != managerGroupId) {
        throw Exception(
          'Không có quyền: đơn #$leaveId không thuộc nhóm của bạn. '
          'Manager chỉ được duyệt đơn của nhân viên trong nhóm mình quản lý.',
        );
      }
    } on Exception {
      rethrow; // ném lại Exception đã có message
    } catch (e) {
      throw Exception(
        'ApproveLeaveUc: Không thể xác minh quyền hạn của Manager. Chi tiết: $e',
      );
    }
  }
}
