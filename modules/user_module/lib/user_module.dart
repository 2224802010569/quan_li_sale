import 'package:flutter/material.dart';
import 'package:user_module/output/user_event.dart';
import 'view/common/login_view.dart';
import 'view/home_view.dart';

class UserScreen extends StatelessWidget {
  final Function(UserEvent) onEvent;
  final String view;

  const UserScreen({super.key, required this.onEvent, this.view = ''});

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case 'HOME':
        return HomeView();
      default:
        return LoginView(onEvent: onEvent);    
    }
  }
}
