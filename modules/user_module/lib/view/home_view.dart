import 'package:flutter/material.dart';
import '../logic_uc/logout_uc.dart';

class HomeView extends StatelessWidget {
  final logoutUC = LogoutUC();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logoutUC.execute();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _item(Icons.person, "Profile", () {
            Navigator.pushNamed(context, "/profile");
          }),
          _item(Icons.lock, "Change Password", () {
            Navigator.pushNamed(context, "/change");
          }),
          _item(Icons.people, "Manage User", () {
            Navigator.pushNamed(context, "/manage");
          }),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String text, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 40), Text(text)],
        ),
      ),
    );
  }
}
