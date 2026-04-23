import 'package:user_module/logic_data/session_manager.dart';
import '../logic_data/user_data.dart';
import '../entity/user.dart';

class LoginUC {
  final _data = UserData();
  final _session = SessionManager();

  Future<User?> execute(String id, String pass) async {
    if (id.trim().isEmpty || pass.isEmpty) {
      throw Exception("Thiếu thông tin");
    }

    final user = await _data.login(id, pass);

    if (user != null) {
      await _session.saveUser(user);
    }

    return user;
  }
}
