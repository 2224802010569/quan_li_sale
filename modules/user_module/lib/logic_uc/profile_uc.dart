import 'dart:typed_data';

import '../logic_data/user_data.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import '../entity/user.dart';

class ProfileUC {
  final _data = UserData();

  Future<User> execute({String? userId}) async {
    final storage = get<AppStorage>();
    final current = storage.get<Map<String, dynamic>>('user');

    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    final isManager = current['role'] == 'Manager';
    final targetId = userId ?? current['id'];
    if (targetId != current['id'] && !isManager) {
      throw Exception("Không có quyền xem user khác");
    }

    final users = await _data.getAllUsers();

    return users.firstWhere(
      (u) => u.id == targetId,
      orElse: () => throw Exception("Không tìm thấy user"),
    );
  }

  Future<User> updateCurrentUser({
    required String fullName,
    required String email,
    required String phone,
    Uint8List? avatarBytes,
    String? avatarFileName,
  }) async {
    final storage = get<AppStorage>();
    final current = storage.get<Map<String, dynamic>>('user');

    if (current == null) {
      throw Exception("Chưa đăng nhập");
    }

    final normalizedFullName = fullName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();

    if (normalizedFullName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPhone.isEmpty) {
      throw Exception("Vui lòng nhập đầy đủ họ tên, email và số điện thoại");
    }

    if (!normalizedEmail.contains('@')) {
      throw Exception("Email không hợp lệ");
    }

    final user = await execute();
    var avatarPath = user.avatarPath;

    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      avatarPath = await _data.uploadAvatar(
        userId: user.id,
        bytes: avatarBytes,
        fileName: avatarFileName ?? 'avatar.jpg',
      );
    }

    final updatedUser = user.copyWith(
      fullName: normalizedFullName,
      email: normalizedEmail,
      phone: normalizedPhone,
      avatarPath: avatarPath,
    );

    final updated = await _data.updateProfile(updatedUser);
    if (!updated) {
      throw Exception(
        "Supabase từ chối cập nhật thông tin cá nhân. Kiểm tra quyền update bảng users cho role anon.",
      );
    }

    final refreshedUser = await _data.getById(updatedUser.id) ?? updatedUser;

    await storage.set('user', {
      'id': refreshedUser.id,
      'role': refreshedUser.role,
      'groupId': refreshedUser.groupId,
      'email': refreshedUser.email,
      'phone': refreshedUser.phone,
      'fullName': refreshedUser.fullName,
      'avatarUrl': refreshedUser.avatarUrl,
      'avatarPath': refreshedUser.avatarPath,
    });

    return refreshedUser;
  }
}
