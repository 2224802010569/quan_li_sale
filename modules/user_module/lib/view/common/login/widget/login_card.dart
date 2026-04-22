import 'package:flutter/material.dart';
import 'package:user_module/view/common/forgot_password/forgot_password_view.dart';
import 'input_field.dart';

class LoginCard extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController passController;
  final VoidCallback onLogin;
  final String error;

  const LoginCard({
    super.key,
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

          const Text(
            'Chào mừng trở lại',
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 32),

          /// USERNAME / EMAIL
          InputField(
            label: 'TÊN ĐĂNG NHẬP',
            controller: idController,
            hint: 'Tên đăng nhập hoặc mail',
          ),

          const SizedBox(height: 24),

          /// PASSWORD
          InputField(
            label: 'MẬT KHẨU',
            controller: passController,
            hint: 'Nhập mật khẩu',
            obscure: true,
          ),

          /// QUÊN MẬT KHẨU
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordView(),
                  ),
                );
              },
              child: const Text("Quên mật khẩu?"),
            ),
          ),

          /// ERROR
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 16),

          /// BUTTON LOGIN
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
