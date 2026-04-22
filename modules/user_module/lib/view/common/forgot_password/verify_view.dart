import 'package:flutter/material.dart';
import 'package:user_module/view/common/change_password/change_password_view.dart';
import 'dart:async';
import '../../../logic_uc/forgot_password_uc.dart';
import 'widget/verify_card.dart';

class VerifyView extends StatefulWidget {
  final String email;

  const VerifyView({super.key, required this.email});

  @override
  State<VerifyView> createState() => _State();
}

class _State extends State<VerifyView> {
  final codeCtrl = TextEditingController();
  final _uc = ForgotPasswordUC();

  String error = "";
  int seconds = 300;
  bool loading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (seconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() => seconds--);
    });
  }

  String formatTime() {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> handleVerify() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final ok = await _uc.verifyCode(email: widget.email, code: codeCtrl.text);

      if (!mounted) {
        return;
      }

      if (ok) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordView(email: widget.email),
          ),
        );
      } else {
        setState(() => error = "Mã không đúng");
      }
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
    _timer?.cancel();
    codeCtrl.dispose();
    super.dispose();
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
            child: VerifyCard(
              codeCtrl: codeCtrl,
              onVerify: handleVerify,
              error: error,
              time: formatTime(),
              loading: loading,
            ),
          ),
        ),
      ),
    );
  }
}
