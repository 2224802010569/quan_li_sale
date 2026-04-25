import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppStorage {
  final Map<String, dynamic> _data = {};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final rawUser = _prefs?.getString('user');
    if (rawUser != null) {
      _data['user'] = jsonDecode(rawUser);
    }
  }

  T? get<T>(String key) {
    return _data[key] as T?;
  }

  Future<void> set(String key, dynamic value) async {
    _data[key] = value;
    await _saveToDisk(key, value);
  }

  void remove(String key) {
    _data.remove(key);
    _prefs?.remove(key);
  }

  void clear() {
    _data.clear();
    _prefs?.clear();
  }

  Future<void> _saveToDisk(String key, dynamic value) async {
    if (_prefs == null) return;

    if (value is Map || value is List) {
      await _prefs!.setString(key, jsonEncode(value));
    } else if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    }
  }
}
