class AppStorage {
  static Map<String, dynamic> _storage = {};

  static void saveUser(Map<String, dynamic> data) {
    _storage['user'] = data;
  }

  static Map<String, dynamic>? getUser() {
    return _storage['user'];
  }

  static void clear() {
    _storage.clear();
  }
}
