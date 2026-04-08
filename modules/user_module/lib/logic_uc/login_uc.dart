import '../logic_data/user_data.dart';
import '../entity/user.dart';

class LoginUC {
  final _data = UserData();

  User? execute(String phone, String password) {
    if (phone.isEmpty || password.isEmpty) {
      throw Exception("Thiếu thông tin");
    }

    return _data.login(phone, password);
  }
}
