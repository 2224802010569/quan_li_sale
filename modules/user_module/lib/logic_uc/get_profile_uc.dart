import '../storage/app_storage.dart';

class GetProfileUC {
  Map<String, dynamic>? execute() {
    return AppStorage.getUser();
  }
}
