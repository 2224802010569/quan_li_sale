import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/view/common/login/widget/login_header.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onChangeRole;
  final VoidCallback? onEdit;
  final VoidCallback? onLogout;
  final bool changingRole;
  final bool editingProfile;

  const ProfileCard({
    super.key,
    required this.user,
    this.onChangeRole,
    this.onEdit,
    this.onLogout,
    this.changingRole = false,
    this.editingProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LoginHeader(),
          const SizedBox(height: 24),

          Center(child: _avatar()),
          const SizedBox(height: 16),

          /// NAME
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _info("Email", user.email),
          _info("Phone", user.phone),
          _info("Role", user.role),
          _info("Group", user.groupId),
          if (onEdit != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: editingProfile ? null : onEdit,
                icon: editingProfile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit),
                label: Text(editingProfile ? "Đang lưu..." : "Chỉnh sửa"),
              ),
            ),
          ],
          if (onChangeRole != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: changingRole ? null : onChangeRole,
                child: changingRole
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Đổi vai trò"),
              ),
            ),
          ],
          if (onLogout != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 88, child: Text(label)),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, softWrap: true),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final avatarUrl = user.avatarUrl.trim();
    final fallbackText = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().substring(0, 1).toUpperCase()
        : user.id.substring(0, 1).toUpperCase();

    if (avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: const Color(0xFFE8EEF8),
        child: Text(
          fallbackText,
          style: const TextStyle(
            color: Color(0xFF001D4E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 44,
      backgroundColor: const Color(0xFFE8EEF8),
      backgroundImage: NetworkImage(avatarUrl),
    );
  }
}
