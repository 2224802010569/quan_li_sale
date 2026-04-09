import '../entity/user.dart';

class UserData {
  final List<Map<String, dynamic>> _fakeDb = [
    {'id': '1', 'phone': '1', 'password': '123', 'role': 'Sale'},
    {'id': '2', 'phone': '2', 'password': '123', 'role': 'Manager'},
  ];

  User? login(String phone, String password) {
    try {
      final data = _fakeDb.firstWhere(
        (e) => e['phone'] == phone && e['password'] == password,
      );

      return User(
        id: data['id'],
        phone: data['phone'],
        role: data['role'],
        token: "fake_token_${data['id']}",
      );
    } catch (_) {
      return null;
    }
  }
}
