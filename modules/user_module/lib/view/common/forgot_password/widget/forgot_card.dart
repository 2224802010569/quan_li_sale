import 'package:flutter/material.dart';
import 'package:user_module/view/common/forgot_password/widget/input_field.dart';

class ForgotCard extends StatelessWidget {
  final TextEditingController emailCtrl;
  final VoidCallback onSend;
  final String error;
  final bool loading;

  const ForgotCard({
    super.key,
    required this.emailCtrl,
    required this.onSend,
    required this.error,
    required this.loading,
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
            "Khôi phục tài khoản",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text("Nhập email để nhận mã xác thực"),

          const SizedBox(height: 24),

          InputField(
            label: "EMAIL",
            controller: emailCtrl,
            hint: "name@gmail.com",
          ),

          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),

          const SizedBox(height: 24),

          GestureDetector(
            onTap: loading ? null : onSend,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Gửi mã xác thực",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
