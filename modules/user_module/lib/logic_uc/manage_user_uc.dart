import '../logic_data/user_data.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import '../entity/user.dart';

class ManagerUserUC {
  final _data = UserData();

  Future<List<User>> getUsers() async {
    final storage = get<AppStorage>();
    final current = storage.get<Map<String, dynamic>>('user');

    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    if (current['role'] != 'Manager') {
      throw Exception("Không có quyền");
    }

    final groupId = current['groupId'];

    final users = await _data.getAllUsers();

    return users
        .where((u) => u.groupId == groupId && u.role == 'Sale')
        .toList();
  }

  Future<void> deleteUser(User user) async {
    final storage = get<AppStorage>();
    final current = storage.get<Map<String, dynamic>>('user');

    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    if (current['role'] != 'Manager') {
      throw Exception("Không có quyền xóa nhân viên");
    }

    if (user.role != 'Sale' || user.groupId != current['groupId']) {
      throw Exception("Chỉ được xóa nhân viên Sale trong cùng group");
    }

    final deleted = await _data.deleteUserRemote(user.id);
    if (!deleted) {
      throw Exception("Không thể xóa nhân viên trên Supabase");
    }
  }
}
