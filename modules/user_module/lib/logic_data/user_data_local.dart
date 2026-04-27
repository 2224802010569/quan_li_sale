import '../entity/user.dart';

class UserDataLocal {
  final List<Map<String, dynamic>> _data = [
    {
      'id': 'Sale01',
      'username': 'sale01',
      'email': 'sale01@example.com',
      'password': '123',
      'phone': '0123456789',
      'role': 'Sale',
      'fullName': 'Nguyen Van A',
      'full_name': 'Nguyen Van A',
      'groupId': 'G1',
      'group_id': 'G1',
    },
    {
      'id': 'Mana01',
      'username': 'mana01',
      'email': 'manager01@example.com',
      'password': '123',
      'phone': '0123456789',
      'role': 'Manager',
      'fullName': 'Nguyen Van B',
      'full_name': 'Nguyen Van B',
      'groupId': 'G1',
      'group_id': 'G1',
    },
  ];

  Map<String, dynamic>? findUser(String fullName, String password) {
    try {
      return _data.firstWhere(
        (e) => e['fullName'] == fullName && e['password'] == password,
      );
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> getAll() => _data;

  void insert(Map<String, dynamic> user) {
    _data.add(user);
  }
}
