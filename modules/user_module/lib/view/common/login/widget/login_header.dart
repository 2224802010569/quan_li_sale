import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

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
