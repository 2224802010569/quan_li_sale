import 'package:flutter/material.dart';
import '../logic_uc/get_profile_uc.dart';

class ProfileView extends StatelessWidget {
  final _uc = GetProfileUC();

  @override
  Widget build(BuildContext context) {
    final user = _uc.execute();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: user == null
          ? const Center(child: Text("No user"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("User ID: ${user['id']}"),
                  Text("Role: ${user['role']}"),
                  Text("Group ID: ${user['groupId']}"),
                ],
              ),
            ),
    );
  }
}
