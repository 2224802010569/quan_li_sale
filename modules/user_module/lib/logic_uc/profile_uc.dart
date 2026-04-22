import '../logic_data/user_data.dart';
import '../storage/app_storage.dart';
import '../entity/user.dart';

class ProfileUC {
  final _data = UserData();

  Future<User> execute({String? userId}) async {
    final current = AppStorage.getUser();

    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    final isManager = current['role'] == 'Manager';

    /// Nếu không truyền → lấy chính mình
    final targetId = userId ?? current['id'];

    /// ❗ Rule: chỉ manager mới xem người khác
    if (targetId != current['id'] && !isManager) {
      throw Exception("Không có quyền xem user khác");
    }

    final users = await _data.getAllUsers();

    return users.firstWhere(
      (u) => u.id == targetId,
      orElse: () => throw Exception("Không tìm thấy user"),
    );
  }
}
