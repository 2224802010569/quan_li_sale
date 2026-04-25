import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:user_module/logic_data/session_manager.dart';

class ManagerInput {
  final _session = SessionManager();

  bool canOpen() {
    final user = _session.getUser();
    return user != null && user['role'] == 'Manager';
  }
}
