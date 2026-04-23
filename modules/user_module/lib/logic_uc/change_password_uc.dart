import 'package:user_module/logic_data/session_manager.dart';
import '../logic_data/user_data.dart';

class ChangePasswordUC {
  final _data = UserData();
  final _session = SessionManager();

  Future<void> execute({
    required String email,
    required String newPassword,
  }) async {
    if (newPassword.trim().length < 6) {
      throw Exception("Mật khẩu phải >= 6 ký tự");
    }

    final ok = await _data.updatePasswordByEmail(
      email.trim().toLowerCase(),
      newPassword.trim(),
    );

    if (!ok) {
      throw Exception("Không thể cập nhật mật khẩu");
    }

    final user = await _data.login(email, newPassword);

    if (user == null) {
      throw Exception("Tự động đăng nhập thất bại");
    }

    await _session.saveUser(user);
  }
}
