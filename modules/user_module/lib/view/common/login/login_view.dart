import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/login_uc.dart';
import 'package:user_module/output/user_event.dart';
import 'widget/login_header.dart';
import 'widget/login_card.dart';

class LoginView extends StatefulWidget {
  final Function(UserEvent) onEvent;
  const LoginView({super.key, required this.onEvent});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final idController = TextEditingController();
  final passController = TextEditingController();

  final _loginUC = LoginUC();

  String error = '';

  Future<void> handleLogin() async {
    try {
      final user = await _loginUC.execute(
        idController.text,
        passController.text,
      );

      if (user != null) {
        widget.onEvent(
          UserEvent.loginSuccess({
            'user': {
              'id': user.id,
              'role': user.role,
              'groupId': user.groupId,
              'email': user.email,
              'phone': user.phone,
              'fullName': user.fullName,
            },
          }),
        );
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
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 24),
                  LoginCard(
                    idController: idController,
                    passController: passController,
                    onLogin: handleLogin,
                    error: error,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
