import '../storage/app_storage.dart';

class LogoutUC {
  void execute() {
    AppStorage.clear();
  }
}
