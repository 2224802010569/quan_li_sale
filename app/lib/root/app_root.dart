import 'package:flutter/material.dart';
import 'package:user_module/output/user_output.dart';
import 'user_root.dart';

class AppRoot extends StatelessWidget {
  final String currentModule;
  final Function(UserOutput) onOutput;

  const AppRoot({
    super.key,
    required this.currentModule,
    required this.onOutput,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentModule) {
      case 'USER':
        return UserRoot(onOutput: onOutput);

      default:
        return const Scaffold(body: Center(child: Text('Unknown module')));
    }
  }
}
