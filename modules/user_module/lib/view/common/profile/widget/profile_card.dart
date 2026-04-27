import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/view/common/login/widget/login_header.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onChangeRole;
  final bool changingRole;

  const ProfileCard({
    super.key,
    required this.user,
    this.onChangeRole,
    this.changingRole = false,
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
        children: [
          const LoginHeader(),
          const SizedBox(height: 24),

          /// NAME
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _info("Email", user.email),
          _info("Phone", user.phone),
          _info("Role", user.role),
          _info("Group", user.groupId),
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
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
