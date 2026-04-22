import '../logic_data/user_data.dart';
import '../entity/user.dart';
import '../storage/app_storage.dart';

class LoginUC {
  final _data = UserData();

  Future<User?> execute(String id, String pass) async {
    final user = await _data.login(id, pass);
    return user;
  }
}
