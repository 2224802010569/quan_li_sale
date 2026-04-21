import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import '../entity/user.dart';
import 'user_data_local.dart';

class UserData {
  final String table = 'users';
  final supabase = get<SupabaseConnect>().client;

  final _local = UserDataLocal();

  User convertToUser(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      password: data['password'],
      phone: data['phone'],
      role: data['role'],
      fullName: data['full_name'],
      groupId: data['group_id'],
    );
  }

  Future<bool> insertUser(User user) async {
    try {
      await supabase?.from(table).insert({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'phone': user.phone,
        'role': user.role,
        'full_name': user.fullName,
        'group_id': user.groupId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await supabase?.from(table).select();

      return response!.map<User>((item) => convertToUser(item)).toList();
    } catch (_) {
      return _local.getAll().map<User>((item) => convertToUser(item)).toList();
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await supabase
          ?.from(table)
          .update({
            'password': user.password,
            'phone': user.phone,
            'role': user.role,
            'fullName': user.fullName,
            'groupId': user.groupId,
          })
          .eq('id', user.id);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await supabase?.from(table).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> login(String username, String password) async {
    final users = await getAllUsers();
    return users.where((u) => (u.username == username || u.email == username) && u.password == password).toList().firstOrNull;
  }
}
