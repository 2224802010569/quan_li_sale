import '../entity/leave_request_entity.dart';
import '../entity/leave_status.dart';
import '../logic_data/leave_data.dart';

/// Use-case: Sale nộp đơn đăng ký nghỉ phép.
///
/// Trách nhiệm:
///   1. Validate rule nghiệp vụ (ngày hợp lệ).
///   2. Gọi [LeaveData.insertLeave] để lưu vào DB.
///   3. Trả về entity vừa tạo (fetch lại từ DB).
///
/// Throw [Exception] với message tiếng Việt nếu vi phạm rule hoặc lỗi DB.
class SubmitLeaveUc {
  final LeaveData _leaveData;

  const SubmitLeaveUc(this._leaveData);

  /// Nộp đơn nghỉ phép.
  ///
  /// [userId]    — UUID của Sale đang đăng ký.
  /// [startDate] — Ngày bắt đầu nghỉ.
  /// [endDate]   — Ngày kết thúc nghỉ.
  /// [reason]    — Lý do nghỉ.
  /// [data]      — Metadata mở rộng tuỳ chọn.
  ///
  /// Trả về [LeaveRequestEntity] vừa được tạo trong DB.
  Future<LeaveRequestEntity> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    Map<String, dynamic>? data,
  }) async {
    // -------------------------------------------------------------------------
    // Bước 1: Validate rule nghiệp vụ
    // -------------------------------------------------------------------------
    _validate(startDate: startDate, endDate: endDate, reason: reason);

    // -------------------------------------------------------------------------
    // Bước 2: Tạo entity tạm (id = 0, createdAt = now — sẽ bị ghi đè bởi DB)
    // -------------------------------------------------------------------------
    final draft = LeaveRequestEntity(
      id: 0, // placeholder — DB sẽ auto-generate
      userId: userId,
      startDate: _normalizeDate(startDate),
      endDate: _normalizeDate(endDate),
      reason: reason.trim(),
      status: LeaveStatus.pending,
      createdAt: DateTime.now().toUtc(),
      data: data,
    );

    // -------------------------------------------------------------------------
    // Bước 3: Lưu vào DB
    // -------------------------------------------------------------------------
    await _leaveData.insertLeave(draft);

    // -------------------------------------------------------------------------
    // Bước 4: Fetch lại danh sách để lấy bản ghi mới nhất (có id thật từ DB)
    // -------------------------------------------------------------------------
    try {
      final list = await _leaveData.getLeavesByUser(userId);
      if (list.isEmpty) {
        throw Exception('Nộp đơn thành công nhưng không thể tải lại dữ liệu.');
      }
      // Bản ghi mới nhất luôn ở đầu (sorted by created_at DESC)
      return list.first;
    } catch (e) {
      // Nếu fetch thất bại, vẫn thành công về mặt nghiệp vụ
      // Ném lại với thông báo rõ ràng
      throw Exception('Đơn đã được nộp nhưng không thể tải lại: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Validate toàn bộ rule nghiệp vụ. Throw [Exception] nếu vi phạm.
  void _validate({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    final today = _normalizeDate(DateTime.now());
    final normalizedStart = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);

    // Rule 1: Lý do không được rỗng
    if (reason.trim().isEmpty) {
      throw Exception('Vui lòng nhập lý do nghỉ phép.');
    }

    // Rule 2: Ngày bắt đầu không được ở quá khứ
    if (normalizedStart.isBefore(today)) {
      throw Exception(
        'Ngày bắt đầu nghỉ không hợp lệ: '
        'không thể đăng ký nghỉ cho ngày đã qua (${_formatDate(normalizedStart)}).',
      );
    }

    // Rule 3: Ngày kết thúc phải >= ngày bắt đầu
    if (normalizedEnd.isBefore(normalizedStart)) {
      throw Exception(
        'Ngày kết thúc (${_formatDate(normalizedEnd)}) '
        'không thể trước ngày bắt đầu (${_formatDate(normalizedStart)}).',
      );
    }
  }

  /// Chuẩn hoá DateTime về 00:00:00 để so sánh chỉ phần date.
  DateTime _normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Format ngày sang dd/MM/yyyy để hiển thị trong message lỗi.
  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}
