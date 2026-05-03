// modules/user_module/lib/service/session_manager.dart

import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import '../entity/user.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _storage = get<AppStorage>();

  /// Lưu user sau login / đổi mật khẩu
  Future<void> saveUser(User user) async {
    await get<AppStorage>().set('user', {
      'id': user.id,
      'role': user.role,
      'groupId': user.groupId,
      'email': user.email,
      'phone': user.phone,
      'fullName': user.fullName,
      'avatarUrl': user.avatarUrl,
      'avatarPath': user.avatarPath,
    });
  }

  /// Lấy user hiện tại
  Map<String, dynamic>? getUser() {
    return _storage.get<Map<String, dynamic>>('user');
  }

  /// Clear khi logout
  void clear() {
    _storage.clear();
  }

  /// Check login
  bool isLoggedIn() {
    return getUser() != null;
  }
}
