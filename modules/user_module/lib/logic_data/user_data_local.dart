import '../entity/user.dart';

class UserDataLocal {
  final List<Map<String, dynamic>> _data = [
    {
      'id': 'Sale01',
      'password': '123',
      'phone': '0123456789',
      'role': 'Sale',
      'fullName': 'Nguyen Van A',
      'groupId': 'G1',
    },
    {
      'id': 'Mana01',
      'password': '123',
      'phone': '0123456789',
      'role': 'Manager',
      'fullName': 'Nguyen Van B',
      'groupId': 'G1',
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
}
