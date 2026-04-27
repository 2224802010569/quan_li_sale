import '../entity/user.dart';
import '../logic_data/session_manager.dart';
import '../logic_data/user_data.dart';

class AddUserUC {
  final _data = UserData();
  final _session = SessionManager();

  Future<User> execute({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final current = _session.getUser();
    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    if (current['role'] != 'Manager') {
      throw Exception("Không có quyền thêm nhân viên");
    }

    final normalizedFullName = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();

    if (normalizedFullName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPhone.isEmpty) {
      throw Exception("Vui lòng nhập đầy đủ thông tin");
    }

    if (!normalizedEmail.contains('@')) {
      throw Exception("Email không hợp lệ");
    }

    final existingUser = await _data.getByEmail(normalizedEmail);
    if (existingUser != null) {
      throw Exception("Email đã tồn tại");
    }

    final generatedId = _generateUserId();
    final generatedUsername = _generateUsername(normalizedEmail, generatedId);
    const defaultPassword = '123456';
    final groupId = (current['groupId'] ?? '').toString();

    final user = User(
      id: generatedId,
      username: generatedUsername,
      email: normalizedEmail,
      password: defaultPassword,
      phone: normalizedPhone,
      role: 'Sale',
      fullName: normalizedFullName,
      groupId: groupId,
    );

    final inserted = await _data.insertUser(user);
    if (!inserted) {
      throw Exception("Không thể tạo nhân viên mới");
    }

    return user;
  }

  String _generateUserId() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'Sale${stamp.substring(stamp.length - 6)}';
  }

  String _generateUsername(String email, String userId) {
    final prefix = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (prefix.isEmpty) {
      return userId.toLowerCase();
    }
    return '${prefix.toLowerCase()}${userId.substring(userId.length - 3)}';
  }
}
