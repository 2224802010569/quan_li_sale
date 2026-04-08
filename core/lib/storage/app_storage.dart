class AppStorage {
  String? token;
  String? userId;
  String? role;

  bool get isLoggedIn => token != null;

  void clear() {
    token = null;
    userId = null;
    role = null;
  }
}
