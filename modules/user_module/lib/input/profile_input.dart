import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:user_module/logic_data/session_manager.dart';

class ProfileInput {
  final String? userId;

  ProfileInput({this.userId});

  bool canOpen() {
    final _session = SessionManager();
    final current = _session.getUser();

    if (current == null) return false;

    final isManager = current['role'] == 'Manager';

    /// nếu xem người khác → phải là manager
    if (userId != null && userId != current['id'] && !isManager) {
      return false;
    }

    return true;
  }
}
