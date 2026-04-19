import '../entity/user.dart';

class UserData {
  final List<Map<String, dynamic>> _fakeDb = [
    {
      'id': 'Sale01',
      'password': '123',
      'phone': '0991231232',
      'role': 'Sale',
      'fullName': 'Nguyen Van A',
      'groupId': 'Sale',
    },
    {
      'id': 'QuanLy01',
      'password': '124',
      'phone': '0991231233',
      'role': 'Manager',
      'fullName': 'Tran Van B',
      'groupId': 'Manager',
    },
  ];

  User? login(String id, String password) {
    try {
      final data = _fakeDb.firstWhere(
        (e) => e['id'] == id && e['password'] == password,
      );

      return User(
        id: data['id'],
        phone: data['phone'],
        role: data['role'],
        password: data['password'],
        fullName: data['fullName'] ?? '',
        groupId: data['groupId'] ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
