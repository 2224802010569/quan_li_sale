/// Trạng thái đơn nghỉ phép.
/// Mapping với giá trị varchar trong bảng leave_requests.status
enum LeaveStatus {
  pending,
  approved,
  rejected;

  /// Chuyển từ string DB → enum
  static LeaveStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'pending':
      default:
        return LeaveStatus.pending;
    }
  }

  /// Chuyển enum → string lưu vào DB
  String toDbString() {
    switch (this) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.pending:
        return 'Pending';
    }
  }

  /// Label hiển thị tiếng Việt
  String get label {
    switch (this) {
      case LeaveStatus.approved:
        return 'Đã duyệt';
      case LeaveStatus.rejected:
        return 'Từ chối';
      case LeaveStatus.pending:
        return 'Đang chờ';
    }
  }
}
