import '../storage/app_storage.dart';

class LoginInput {
  bool canOpen() {
    return AppStorage.getUser() == null;
  }
}
