import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

class LogoutUC {
  void execute() {
    final storage = get<AppStorage>();
    storage.clear();
  }
}
