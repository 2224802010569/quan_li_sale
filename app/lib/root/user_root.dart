import 'package:flutter/material.dart';
import 'package:user_module/output/user_output.dart';
import 'package:user_module/user_module.dart';

class UserRoot extends StatelessWidget {
  final Function(UserOutput) onOutput;

  const UserRoot({super.key, required this.onOutput});

  @override
  Widget build(BuildContext context) {
    return UserScreen(onOutput: onOutput);
  }
}
