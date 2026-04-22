import '../storage/app_storage.dart';

class ManagerInput {
  bool canOpen() {
    final user = AppStorage.getUser();
    return user != null && user['role'] == 'Manager';
  }
}