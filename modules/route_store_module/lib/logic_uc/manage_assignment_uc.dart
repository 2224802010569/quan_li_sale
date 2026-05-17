import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/logic_data/assignment_data.dart';

final manageAssignmentUcProvider = Provider<ManageAssignmentUc>((ref) {
  return ManageAssignmentUc(ref.read(assignmentDataProvider));
});

class ManageAssignmentUc {
  final AssignmentData _assignmentData;

  ManageAssignmentUc(this._assignmentData);

  /// Phân công tuyến cho Sale
  /// Throws Exception nếu có conflict (trùng lịch)
  Future<AssignmentEntity> assignRouteToSale(String userId, int routeId, DateTime date) async {
    // Validation: kiểm tra trùng lịch (theo instructions.md - Assignment Rules)
    final hasConflict = await _assignmentData.checkConflict(userId, date);
    if (hasConflict) {
      throw Exception('Sale đã có tuyến được gán trong ngày ${date.toIso8601String().split('T')[0]}. Không thể trùng lịch assignment.');
    }

    final assignment = AssignmentEntity(
      assignmentId: 0,
      userId: userId,
      routeId: routeId,
      isSupport: 1, // Mặc định là tuyến chính
      assignedDate: date,
    );
    return await _assignmentData.upsertAssignment(assignment);
  }

  /// Điều chuyển người hỗ trợ (Reassignment)
  /// Khi sale đang được phân công mà xin nghỉ phép
  Future<void> reassignToSupport(int assignmentId, String newUserId) async {
    await _assignmentData.reassignRoute(assignmentId, newUserId);
  }

  /// Tạo assignment hỗ trợ mới (is_support = 2)
  /// Dùng khi có sale xin nghỉ phép và cần người đi hỗ trợ
  Future<AssignmentEntity> createSupportAssignment({
    required String userId,
    required int routeId,
    required DateTime date,
  }) async {
    // Validation trùng lịch
    final hasConflict = await _assignmentData.checkConflict(userId, date);
    if (hasConflict) {
      throw Exception('Sale hỗ trợ đã có tuyến trong ngày này. Không thể trùng lịch.');
    }

    return await _assignmentData.createSupportAssignment(
      userId: userId,
      routeId: routeId,
      date: date,
    );
  }

  /// Lấy assignments theo route (Manager xem ai được gán)
  Future<List<AssignmentEntity>> getAssignmentsByRoute(int routeId) async {
    return await _assignmentData.getAssignmentsByRoute(routeId);
  }

  /// Lấy assignments trong ngày (Manager view)
  Future<List<AssignmentEntity>> getAssignmentsByDate(DateTime date) async {
    return await _assignmentData.getAssignmentsByDate(date);
  }

  /// Xóa phân công
  Future<void> deleteAssignment(int assignmentId) async {
    await _assignmentData.deleteAssignment(assignmentId);
  }
}
