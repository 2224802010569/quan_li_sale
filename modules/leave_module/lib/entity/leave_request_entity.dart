import 'leave_status.dart';

/// Entity đại diện cho một đơn nghỉ phép.
/// Mapping 1-1 với bảng `leave_requests` trong Supabase.
/// Thuần Dart — không import Flutter hay Supabase.
class LeaveRequestEntity {
  /// PK, auto-increment (bigint)
  final int id;

  /// FK → users.id
  final String userId;

  /// Ngày bắt đầu nghỉ (lưu dạng 'yyyy-MM-dd' trong DB)
  final DateTime startDate;

  /// Ngày kết thúc nghỉ (lưu dạng 'yyyy-MM-dd' trong DB)
  final DateTime endDate;

  /// Lý do nghỉ
  final String reason;

  /// Trạng thái: Pending / Approved / Rejected
  final LeaveStatus status;

  /// FK → users.id (Manager đã duyệt); null nếu chưa duyệt
  final String? approvedBy;

  /// Timestamp tạo bản ghi (UTC)
  final DateTime createdAt;

  /// Metadata mở rộng dạng JSON (tuỳ chọn)
  final Map<String, dynamic>? data;

  const LeaveRequestEntity({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedBy,
    required this.createdAt,
    this.data,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Tạo entity từ row JSON trả về bởi Supabase
  factory LeaveRequestEntity.fromJson(Map<String, dynamic> json) {
    return LeaveRequestEntity(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String,
      status: LeaveStatus.fromString(json['status'] as String),
      approvedBy: json['approved_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Chuyển entity → Map để INSERT / UPDATE lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'reason': reason,
      'status': status.toDbString(),
      'approved_by': approvedBy,
      'created_at': createdAt.toIso8601String(),
      if (data != null) 'data': data,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Số ngày nghỉ (tính cả ngày bắt đầu và kết thúc)
  int get totalDays => endDate.difference(startDate).inDays + 1;

  /// Tạo bản copy với một số field được thay đổi
  LeaveRequestEntity copyWith({
    int? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    String? approvedBy,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return LeaveRequestEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'LeaveRequestEntity('
        'id: $id, '
        'userId: $userId, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'reason: $reason, '
        'status: ${status.toDbString()}, '
        'approvedBy: $approvedBy, '
        'createdAt: $createdAt'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
