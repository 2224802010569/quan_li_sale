import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import '../entity/user.dart';
import 'user_data_local.dart';

class UserData {
  final String table = 'users';
  get supabase => get<SupabaseConnect>().client;

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
      try {
        _local.insert({
          'id': user.id,
          'username': user.username,
          'email': user.email,
          'password': user.password,
          'phone': user.phone,
          'role': user.role,
          'fullName': user.fullName,
          'full_name': user.fullName,
          'groupId': user.groupId,
          'group_id': user.groupId,
        });
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> insertUserRemote(User user) async {
    final client = supabase;
    if (client == null) {
      throw Exception("Supabase chưa được khởi tạo");
    }

    try {
      await client
          .from(table)
          .insert({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'password': user.password,
            'phone': user.phone,
            'role': user.role,
            'full_name': user.fullName,
            'group_id': user.groupId,
          })
          .select('id')
          .single();
    } catch (e) {
      throw Exception("Supabase không cho thêm nhân viên: $e");
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

  Future<bool> deleteUserRemote(String id) async {
    final client = supabase;
    if (client == null) {
      return false;
    }

    try {
      await client.from(table).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> login(String username, String password) async {
    final users = await getAllUsers();
    return users
        .where(
          (u) =>
              (u.username == username || u.email == username) &&
              u.password == password,
        )
        .toList()
        .firstOrNull;
  }

  Future<User?> getByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await getAllUsers();

    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) {
        return user;
      }
    }

    return null;
  }

  Future<bool> updatePasswordByEmail(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      await supabase
          ?.from(table)
          .update({'password': newPassword})
          .eq('email', normalizedEmail);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> getById(String userId) async {
    final normalizedUserId = userId.trim();
    final users = await getAllUsers();

    for (final user in users) {
      if (user.id.trim() == normalizedUserId) {
        return user;
      }
    }

    return null;
  }

  Future<bool> updateRoleAndGroup({
    required String userId,
    required String role,
    required String groupId,
  }) async {
    final normalizedUserId = userId.trim();

    try {
      await supabase
          ?.from(table)
          .update({'role': role, 'group_id': groupId})
          .eq('id', normalizedUserId);
      return true;
    } catch (_) {
      try {
        final localUser = _local.getAll().firstWhere(
          (item) => item['id'] == normalizedUserId,
        );
        localUser['role'] = role;
        localUser['groupId'] = groupId;
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
