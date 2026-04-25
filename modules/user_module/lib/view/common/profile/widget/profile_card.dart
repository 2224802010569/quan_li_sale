import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/view/common/login/widget/login_header.dart';

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({required this.user});

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
