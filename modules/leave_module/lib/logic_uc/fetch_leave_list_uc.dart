import '../entity/leave_request_entity.dart';
import '../entity/leave_status.dart';
import '../logic_data/leave_data.dart';

/// Use-case: Lấy danh sách đơn nghỉ phép theo role của người dùng.
///
/// - Role `Sale`    → chỉ thấy đơn của chính mình (theo userId).
/// - Role `Manager` → thấy đơn của cả nhóm (theo groupId).
///
/// Hỗ trợ filter tuỳ chọn theo tháng và trạng thái.
/// Kết quả luôn được sort theo created_at giảm dần (mới nhất trước).
class FetchLeaveListUc {
  final LeaveData _leaveData;

  const FetchLeaveListUc(this._leaveData);

  /// Lấy danh sách đơn nghỉ phép.
  ///
  /// [userId]       — UUID của người dùng hiện tại (bắt buộc).
  /// [role]         — `'Sale'` hoặc `'Manager'` (bắt buộc).
  /// [groupId]      — Nhóm của Manager (bắt buộc khi role == 'Manager').
  /// [filterMonth]  — Lọc theo tháng cụ thể (1–12). Null = không lọc.
  /// [filterYear]   — Năm để lọc theo tháng. Mặc định là năm hiện tại.
  /// [filterStatus] — Lọc theo trạng thái. Null = tất cả trạng thái.
  ///
  /// Throw [Exception] nếu role không hợp lệ hoặc Manager thiếu groupId.
  Future<List<LeaveRequestEntity>> call({
    required String userId,
    required String role,
    String? groupId,
    int? filterMonth,
    int? filterYear,
    LeaveStatus? filterStatus,
  }) async {
    // -------------------------------------------------------------------------
    // Bước 1: Validate input
    // -------------------------------------------------------------------------
    final normalizedRole = role.trim().toLowerCase();

    if (normalizedRole != 'sale' && normalizedRole != 'manager') {
      throw Exception(
        'FetchLeaveListUc: Role không hợp lệ "$role". Chỉ chấp nhận "Sale" hoặc "Manager".',
      );
    }

    if (normalizedRole == 'manager' && (groupId == null || groupId.trim().isEmpty)) {
      throw Exception(
        'FetchLeaveListUc: Manager phải có groupId để xem đơn của nhóm.',
      );
    }

    // -------------------------------------------------------------------------
    // Bước 2: Fetch data theo role
    // -------------------------------------------------------------------------
    final List<LeaveRequestEntity> rawList;

    if (normalizedRole == 'sale') {
      rawList = await _leaveData.getLeavesByUser(userId);
    } else {
      rawList = await _leaveData.getLeavesByGroup(groupId!);
    }

    // -------------------------------------------------------------------------
    // Bước 3: Áp dụng filter (xử lý phía client)
    // -------------------------------------------------------------------------
    final int year = filterYear ?? DateTime.now().year;

    final filtered = rawList.where((leave) {
      // Filter theo tháng (dùng start_date làm mốc)
      if (filterMonth != null) {
        final matchMonth = leave.startDate.month == filterMonth &&
            leave.startDate.year == year;
        if (!matchMonth) return false;
      }

      // Filter theo trạng thái
      if (filterStatus != null && leave.status != filterStatus) {
        return false;
      }

      return true;
    }).toList();

    // -------------------------------------------------------------------------
    // Bước 4: Sort theo created_at giảm dần (mới nhất trước)
    // -------------------------------------------------------------------------
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }
}
