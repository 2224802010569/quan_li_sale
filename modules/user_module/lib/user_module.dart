import 'package:flutter/material.dart';
import 'view/login_view.dart';
import 'view/home_view.dart';

class UserScreen extends StatelessWidget {
  final String view;

  const UserScreen({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case 'HOME':
        return HomeView();
      default:
        return LoginView(onOutput: (_) {});
    }
  }
}
