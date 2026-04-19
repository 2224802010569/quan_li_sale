import 'package:flutter/material.dart';
import '../logic_uc/manage_user_uc.dart';

class ManageUserView extends StatelessWidget {
  final uc = ManageUserUC();

  @override
  Widget build(BuildContext context) {
    final users = uc.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: ListView(
        children: users
            .map(
              (e) =>
                  ListTile(title: Text(e['phone']), subtitle: Text(e['role'])),
            )
            .toList(),
      ),
    );
  }
}
