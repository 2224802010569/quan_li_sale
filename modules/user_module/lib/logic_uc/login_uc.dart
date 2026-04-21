import '../logic_data/user_data.dart';
import '../entity/user.dart';
import '../storage/app_storage.dart';

class LoginUC {
  final _data = UserData();

  Future<User?> execute(String id, String password) async {
    if (id.isEmpty || password.isEmpty) {
      throw Exception("Thiếu thông tin");
    }

    final user = await _data.login(id, password);

    if (user != null) {
      AppStorage.saveUser({
        'id': user.id,
        'role': user.role,
        'groupId': user.groupId,
      });
    }

    return user;
  }
}
