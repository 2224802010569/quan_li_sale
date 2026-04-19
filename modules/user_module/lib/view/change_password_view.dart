import 'package:flutter/material.dart';

class ChangePasswordView extends StatefulWidget {
  @override
  State<ChangePasswordView> createState() => _State();
}

class _State extends State<ChangePasswordView> {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();

  String msg = "";

  void handle() {
    if (oldCtrl.text == "123") {
      setState(() => msg = "Đổi mật khẩu thành công");
    } else {
      setState(() => msg = "Sai mật khẩu cũ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Column(
        children: [
          TextField(
            controller: oldCtrl,
            decoration: const InputDecoration(labelText: "Old"),
          ),
          TextField(
            controller: newCtrl,
            decoration: const InputDecoration(labelText: "New"),
          ),
          ElevatedButton(onPressed: handle, child: const Text("Change")),
          Text(msg),
        ],
      ),
    );
  }
}
