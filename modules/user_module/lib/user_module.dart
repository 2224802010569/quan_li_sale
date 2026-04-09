import 'package:flutter/material.dart';
import 'view/login_view.dart';
import 'input/login_input.dart';
import 'output/login_output.dart';

class UserScreen extends StatelessWidget {
  final Function(LoginOutput) onOutput;
  final String view;
  final String? role;

  const UserScreen({
    super.key,
    required this.onOutput,
    required this.view,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    /// STAFF
    // if (view == 'USER_STAFF') {
    //   final input = StaffInput(role: role);

    //   if (!input.canOpen()) {
    //     return const Scaffold(body: Center(child: Text('Không có quyền')));
    //   }

    //   return const StaffView();
    // }

    /// LOGIN
    return LoginView(onOutput: onOutput);
  }
}
