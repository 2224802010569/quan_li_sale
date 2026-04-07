import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  final Function(String) onOutput;
  const UserScreen({super.key, required this.onOutput});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Module')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            onOutput('GO_TO_ORDER'); // test chuyển module
          },
          child: const Text('Go to Order'),
        ),
      ),
    );
  }
}
