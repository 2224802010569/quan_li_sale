import '../storage/app_storage.dart';

class ProfileInput {
  final String? userId;

  ProfileInput({this.userId});

  bool canOpen() {
    final current = AppStorage.getUser();

    if (current == null) return false;

    final isManager = current['role'] == 'Manager';

    /// nếu xem người khác → phải là manager
    if (userId != null && userId != current['id'] && !isManager) {
      return false;
    }

    return true;
  }
}
