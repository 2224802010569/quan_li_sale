class AppStorage {
  final Map<String, dynamic> _data = {};

  T? get<T>(String key) {
    return _data[key] as T?;
  }

  void set(String key, dynamic value) {
    _data[key] = value;
  }

  void remove(String key) {
    _data.remove(key);
  }

  void clear() {
    _data.clear();
  }
}
