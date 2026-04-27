import '../entity/user.dart';
import '../logic_data/session_manager.dart';
import '../logic_data/user_data.dart';

class ChangeRoleUC {
  final _data = UserData();
  final _session = SessionManager();

  Future<User> execute({
    required String targetUserId,
    required String newRole,
  }) async {
    final current = _session.getUser();
    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    final currentRole = (current['role'] ?? '').toString().trim();
    if (currentRole != 'Manager') {
      throw Exception("Chỉ manager mới được đổi vai trò");
    }

    final normalizedTargetUserId = targetUserId.trim();
    if (normalizedTargetUserId.isEmpty) {
      throw Exception("Thiếu nhân viên cần đổi vai trò");
    }

    if (normalizedTargetUserId == current['id']) {
      throw Exception("Không thể tự đổi vai trò của chính mình");
    }

    final normalizedRole = newRole.trim();
    if (normalizedRole != 'Sale' && normalizedRole != 'Manager') {
      throw Exception("Vai trò không hợp lệ");
    }

    final targetUser = await _data.getById(normalizedTargetUserId);
    if (targetUser == null) {
      throw Exception("Không tìm thấy nhân viên");
    }

    if (targetUser.role == normalizedRole) {
      throw Exception("Nhân viên đã có vai trò này");
    }

    final newGroupId = _generateGroupId();
    final updated = await _data.updateRoleAndGroup(
      userId: normalizedTargetUserId,
      role: normalizedRole,
      groupId: newGroupId,
    );

    if (!updated) {
      throw Exception("Không thể đổi vai trò");
    }

    final refreshedUser = await _data.getById(normalizedTargetUserId);
    if (refreshedUser == null) {
      throw Exception("Không thể tải lại thông tin nhân viên");
    }

    return refreshedUser;
  }

  String _generateGroupId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return 'G$millis';
  }
}
