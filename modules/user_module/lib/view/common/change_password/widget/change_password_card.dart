import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/change_password_uc.dart';
import '../../change_password/widget/input_field.dart';

class ChangePasswordCard extends StatefulWidget {
  final String email;

  const ChangePasswordCard({super.key, required this.email});

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final _uc = ChangePasswordUC();

  String error = "";
  bool loading = false;

  Future<void> handle() async {
    final newPass = newCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (newPass.length < 6) {
      setState(() => error = "Mật khẩu phải >= 6 ký tự");
      return;
    }

    if (newPass != confirm) {
      setState(() => error = "Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() {
      loading = true;
      error = "";
    });

    try {
      await _uc.execute(email: widget.email, newPassword: newPass);

      if (!mounted) return;

      /// 🔥 auto login → về home
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

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
            "Đổi mật khẩu",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Text("Email: ${widget.email}"),

          const SizedBox(height: 24),

          InputField(
            label: "MẬT KHẨU MỚI",
            controller: newCtrl,
            hint: "Nhập mật khẩu mới",
            obscure: true,
          ),

          const SizedBox(height: 16),

          InputField(
            label: "XÁC NHẬN",
            controller: confirmCtrl,
            hint: "Nhập lại mật khẩu",
            obscure: true,
          ),

          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),

          const SizedBox(height: 24),

          GestureDetector(
            onTap: loading ? null : handle,
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
                        "Xác nhận",
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
