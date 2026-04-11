import '../logic_data/test_user_data.dart';
import '../entity/test_user.dart';

class TestUserUC {
  final _data = TestUserData();

  Future<void> create(String name, String password) async {
    if (name.isEmpty || password.isEmpty) {
      throw Exception("Thiếu dữ liệu");
    }

    await _data.createUser(name, password);
  }

  Future<List<TestUser>> getAll() async {
    final list = await _data.getUsers();
    return list.map((e) => TestUser.fromMap(e)).toList();
  }
}
