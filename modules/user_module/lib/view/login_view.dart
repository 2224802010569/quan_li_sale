import 'package:flutter/material.dart';
import '../logic_uc/login_uc.dart';
import '../output/user_output.dart';

class LoginView extends StatefulWidget {
  final Function(UserOutput) onOutput;

  const LoginView({super.key, required this.onOutput});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();

  final _loginUC = LoginUC();

  String error = '';

  void handleLogin() {
    try {
      final user = _loginUC.execute(phoneController.text, passController.text);

      if (user != null) {
        widget.onOutput(UserOutput.loginSuccess(user));
      } else {
        setState(() => error = "Sai tài khoản hoặc mật khẩu");
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: handleLogin, child: const Text('Login')),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
