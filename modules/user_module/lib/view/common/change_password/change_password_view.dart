import 'package:flutter/material.dart';
import 'widget/change_password_card.dart';

class ChangePasswordView extends StatelessWidget {
  final String email;

  const ChangePasswordView({super.key, required this.email});

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
              child: ChangePasswordCard(email: email),
            ),
          ),
        ),
      ),
    );
  }
}
