/// leave_input.dart

class LeaveInput {
  final String userId;
  final String userRole;
  final String groupId;

  const LeaveInput({
    required this.userId,
    required this.userRole,
    required this.groupId,
  });

  /// Kiểm tra các field không rỗng
  bool isValid() {
    return userId.trim().isNotEmpty &&
           userRole.trim().isNotEmpty &&
           groupId.trim().isNotEmpty;
  }
}
