import 'dart:typed_data';

import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, StorageException;
import '../entity/user.dart';
import 'user_data_local.dart';

class UserData {
  final String table = 'users';
  final String avatarBucket = 'user_avatars';
  get supabase => get<SupabaseConnect>().client;

  final _local = UserDataLocal();

  User convertToUser(Map<String, dynamic> data) {
    final avatarPath = data['avatar_path'] ?? data['avatarPath'] ?? '';

    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      password: data['password'],
      phone: data['phone'],
      role: data['role'],
      fullName: data['full_name'] ?? data['fullName'] ?? '',
      groupId: data['group_id'] ?? data['groupId'] ?? '',
      avatarUrl: _getAvatarUrl(avatarPath),
      avatarPath: avatarPath,
    );
  }

  Future<bool> insertUser(User user) async {
    try {
      final insertData = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'phone': user.phone,
        'role': user.role,
        'full_name': user.fullName,
        'group_id': user.groupId,
      };
      if (user.avatarPath.isNotEmpty) {
        insertData['avatar_path'] = user.avatarPath;
      }

      await supabase?.from(table).insert(insertData);
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
          'avatarPath': user.avatarPath,
          'avatar_path': user.avatarPath,
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
      final insertData = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'phone': user.phone,
        'role': user.role,
        'full_name': user.fullName,
        'group_id': user.groupId,
      };
      if (user.avatarPath.isNotEmpty) {
        insertData['avatar_path'] = user.avatarPath;
      }

      await client.from(table).insert(insertData).select('id').single();
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
            'full_name': user.fullName,
            'group_id': user.groupId,
            'avatar_path': user.avatarPath,
          })
          .eq('id', user.id);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile(User user) async {
    final updateData = <String, dynamic>{
      'email': user.email,
      'phone': user.phone,
      'full_name': user.fullName,
      'avatar_path': user.avatarPath,
    };
    final client = supabase;

    if (client == null) {
      return _updateLocalProfile(user);
    }

    try {
      await client.from(table).update(updateData).eq('id', user.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _updateLocalProfile(User user) {
    try {
      final localUser = _local.getAll().firstWhere(
        (item) => item['id'] == user.id,
      );
      localUser['email'] = user.email;
      localUser['phone'] = user.phone;
      localUser['fullName'] = user.fullName;
      localUser['full_name'] = user.fullName;
      localUser['avatarPath'] = user.avatarPath;
      localUser['avatar_path'] = user.avatarPath;
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

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = supabase;
    if (client == null) {
      throw Exception("Supabase chưa được khởi tạo");
    }

    final extension = _fileExtension(fileName);
    final contentType = _contentType(extension);
    final storagePath =
        'profiles/${userId.trim()}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      await client.storage
          .from(avatarBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
    } on StorageException catch (e) {
      if (e.statusCode == '403') {
        throw Exception(
          "Supabase Storage từ chối upload avatar (403). Kiểm tra bucket '$avatarBucket' và policy insert/update cho role anon.",
        );
      }
      throw Exception("Không thể upload avatar: ${e.message}");
    } catch (e) {
      throw Exception("Không thể upload avatar: $e");
    }

    return storagePath;
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

  String _getAvatarUrl(String avatarPath) {
    if (avatarPath.trim().isEmpty) {
      return '';
    }

    try {
      return supabase?.storage.from(avatarBucket).getPublicUrl(avatarPath) ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _fileExtension(String fileName) {
    final normalized = fileName.trim().toLowerCase();
    final index = normalized.lastIndexOf('.');
    if (index == -1 || index == normalized.length - 1) {
      return 'jpg';
    }

    final extension = normalized.substring(index + 1);
    if (extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'png' ||
        extension == 'webp') {
      return extension;
    }

    return 'jpg';
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
