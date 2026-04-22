import '../logic_data/user_data.dart';
import '../logic_uc/login_uc.dart';

class ChangePasswordUC {
  final _data = UserData();
  final _loginUC = LoginUC();

  Future<void> execute({
    required String email,
    required String newPassword,
  }) async {
    if (newPassword.trim().length < 6) {
      throw Exception("Mật khẩu phải >= 6 ký tự");
    }

    final normalizedEmail = email.trim().toLowerCase();

    final ok = await _data.updatePasswordByEmail(
      normalizedEmail,
      newPassword.trim(),
    );

    if (!ok) {
      throw Exception("Không thể cập nhật mật khẩu");
    }

    final user = await _data.login(normalizedEmail, newPassword);

    if (user == null) {
      throw Exception("Tự động đăng nhập thất bại");
    }

    await _loginUC.execute(normalizedEmail, newPassword);
  }
}
