import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/login_uc.dart';
import 'package:user_module/output/login_output.dart';

class LoginView extends StatefulWidget {
  final Function(LoginOutput) onOutput;

  const LoginView({super.key, required this.onOutput});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final idController = TextEditingController();
  final passController = TextEditingController();

  final _loginUC = LoginUC();

  String error = '';

  void handleLogin() {
    try {
      final user = _loginUC.execute(idController.text, passController.text);

      if (user != null) {
        widget.onOutput(LoginOutput.loginSuccess(user));
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
                  const _Header(),
                  const SizedBox(height: 24),
                  _LoginCard(
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

// ================= HEADER =================
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'SKA MILK',
          style: TextStyle(
            color: Color(0xFF001D4E),
            fontSize: 24,
            letterSpacing: -1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'NHÀ PHÂN PHỐI SỮA VIỆT NAM',
          style: TextStyle(
            color: Color(0xFF434652),
            fontSize: 12,
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }
}

// ================= CARD =================
class _LoginCard extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController passController;
  final VoidCallback onLogin;
  final String error;

  const _LoginCard({
    required this.idController,
    required this.passController,
    required this.onLogin,
    required this.error,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đăng nhập',
            style: TextStyle(fontSize: 30, color: Color(0xFF001D4E)),
          ),
          const SizedBox(height: 8),
          const Text('Chào mừng trở lại', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 32),

          _Input(
            label: 'TÊN ĐĂNG NHẬP',
            controller: idController,
            hint: 'Nhập mã nhân viên',
          ),

          const SizedBox(height: 24),

          _Input(
            label: 'MẬT KHẨU',
            controller: passController,
            hint: 'Nhập mật khẩu',
            obscure: true,
          ),

          const SizedBox(height: 16),

          if (error.isNotEmpty)
            Text(error, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 24),

          GestureDetector(
            onTap: onLogin,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003178), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Center(
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= INPUT =================
class _Input extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;

  const _Input({
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF434652),
            fontSize: 14,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
