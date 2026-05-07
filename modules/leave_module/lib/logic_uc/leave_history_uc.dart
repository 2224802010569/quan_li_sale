import '../entity/leave_request_entity.dart';
import '../entity/leave_status.dart';
import '../logic_data/leave_data.dart';

/// Kết quả thống kê lịch sử nghỉ phép của một nhân viên trong một năm.
class LeaveHistoryResult {
  /// Tổng số ngày nghỉ đã được duyệt (tính cả ngày bắt đầu và kết thúc).
  final int totalApprovedDays;

  /// Số đơn đang chờ duyệt.
  final int pendingCount;

  /// Số đơn bị từ chối.
  final int rejectedCount;

  /// Số đơn đã được duyệt.
  final int approvedCount;

  /// Năm thống kê.
  final int year;

  /// UUID nhân viên.
  final String employeeId;

  /// Danh sách đơn đã được duyệt (dùng để hiển thị chi tiết nếu cần).
  final List<LeaveRequestEntity> approvedLeaves;

  const LeaveHistoryResult({
    required this.totalApprovedDays,
    required this.pendingCount,
    required this.rejectedCount,
    required this.approvedCount,
    required this.year,
    required this.employeeId,
    required this.approvedLeaves,
  });

  /// Chuyển sang Map để dễ dùng trong UI hoặc log.
  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'year': year,
        'totalApprovedDays': totalApprovedDays,
        'approvedCount': approvedCount,
        'pendingCount': pendingCount,
        'rejectedCount': rejectedCount,
      };

  @override
  String toString() => 'LeaveHistoryResult(${toMap()})';
}

/// Use-case: Thống kê lịch sử nghỉ phép của một nhân viên trong một năm.
///
/// Trả về [LeaveHistoryResult] gồm:
///   - [LeaveHistoryResult.totalApprovedDays] — Tổng ngày nghỉ được duyệt
///   - [LeaveHistoryResult.pendingCount]      — Số đơn đang chờ
///   - [LeaveHistoryResult.rejectedCount]     — Số đơn bị từ chối
///   - [LeaveHistoryResult.approvedCount]     — Số đơn đã được duyệt
///   - [LeaveHistoryResult.approvedLeaves]    — Danh sách đơn approved (để render chi tiết)
class LeaveHistoryUc {
  final LeaveData _leaveData;

  const LeaveHistoryUc(this._leaveData);

  /// Tính thống kê nghỉ phép.
  ///
  /// [employeeId] — UUID của nhân viên cần xem lịch sử.
  /// [year]       — Năm thống kê (mặc định năm hiện tại nếu không truyền).
  ///
  /// Throw [Exception] nếu [employeeId] rỗng hoặc [year] không hợp lệ.
  Future<LeaveHistoryResult> call({
    required String employeeId,
    int? year,
  }) async {
    // -------------------------------------------------------------------------
    // Bước 1: Validate input
    // -------------------------------------------------------------------------
    if (employeeId.trim().isEmpty) {
      throw Exception('LeaveHistoryUc: employeeId không được rỗng.');
    }

    final targetYear = year ?? DateTime.now().year;

    if (targetYear < 2000 || targetYear > DateTime.now().year + 1) {
      throw Exception(
        'LeaveHistoryUc: Năm thống kê không hợp lệ ($targetYear). '
        'Chỉ chấp nhận từ 2000 đến ${DateTime.now().year + 1}.',
      );
    }

    // -------------------------------------------------------------------------
    // Bước 2: Fetch tất cả đơn của nhân viên trong năm
    // -------------------------------------------------------------------------
    final allLeaves = await _leaveData.getLeavesByUserAndYear(
      employeeId,
      targetYear,
    );

    // -------------------------------------------------------------------------
    // Bước 3: Phân loại theo trạng thái
    // -------------------------------------------------------------------------
    final approvedLeaves = allLeaves
        .where((l) => l.status == LeaveStatus.approved)
        .toList();

    final pendingCount = allLeaves
        .where((l) => l.status == LeaveStatus.pending)
        .length;

    final rejectedCount = allLeaves
        .where((l) => l.status == LeaveStatus.rejected)
        .length;

    // -------------------------------------------------------------------------
    // Bước 4: Tính tổng số ngày nghỉ được duyệt
    // -------------------------------------------------------------------------
    final totalApprovedDays = approvedLeaves.fold<int>(
      0,
      (sum, leave) => sum + leave.totalDays,
    );

    // -------------------------------------------------------------------------
    // Bước 5: Trả về kết quả
    // -------------------------------------------------------------------------
    return LeaveHistoryResult(
      totalApprovedDays: totalApprovedDays,
      pendingCount: pendingCount,
      rejectedCount: rejectedCount,
      approvedCount: approvedLeaves.length,
      year: targetYear,
      employeeId: employeeId,
      approvedLeaves: approvedLeaves,
    );
  }
}
