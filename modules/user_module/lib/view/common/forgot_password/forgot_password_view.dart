import 'package:flutter/material.dart';
import '../../../logic_uc/forgot_password_uc.dart';
import 'widget/forgot_card.dart';
import 'verify_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _State();
}

class _State extends State<ForgotPasswordView> {
  final emailCtrl = TextEditingController();
  final _uc = ForgotPasswordUC();

  String error = "";
  bool loading = false;

  Future<void> handleSend() async {
    final email = emailCtrl.text.trim().toLowerCase();

    setState(() {
      loading = true;
      error = "";
    });

    try {
      final ok = await _uc.sendCode(email);

      if (ok && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerifyView(email: email)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ForgotCard(
              emailCtrl: emailCtrl,
              onSend: handleSend,
              error: error,
              loading: loading,
            ),
          ),
        ),
      ),
    );
  }
}
