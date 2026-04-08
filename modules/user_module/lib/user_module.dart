import 'package:flutter/material.dart';
import 'view/login_view.dart';
import 'input/login_input.dart';
import 'output/user_output.dart';

class UserScreen extends StatelessWidget {
  final Function(UserOutput) onOutput;

  const UserScreen({super.key, required this.onOutput});

  @override
  Widget build(BuildContext context) {
    final input = LoginInput();

    if (!input.canOpen()) {
      return const Scaffold(body: Center(child: Text('Không thể mở')));
    }

    return LoginView(onOutput: onOutput);
  }
}
