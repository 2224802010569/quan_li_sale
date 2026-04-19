import 'package:flutter/material.dart';
// Lưu ý: Thay 'user_module' bằng tên package khai báo trong pubspec.yaml của module
import 'package:user_module/user_module.dart';
import 'package:user_module/view/home_view.dart';
import 'package:user_module/view/profile_view.dart';
import 'package:user_module/view/change_password_view.dart';
import 'package:user_module/view/manage_user_view.dart';
import 'package:user_module/view/login_view.dart';

void main() {
  runApp(const MyModuleTestApp());
}

class MyModuleTestApp extends StatelessWidget {
  const MyModuleTestApp({super.key});

  void handleLogin(BuildContext context, output) {
    print("Chuyển từ: ${output.from} sang ${output.to}");
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test User Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/',
      routes: {
        '/': (context) =>
            LoginView(onOutput: (output) => handleLogin(context, output)),

        '/login': (context) =>
            LoginView(onOutput: (output) => handleLogin(context, output)),

        '/home': (context) => HomeView(),
        '/profile': (context) => ProfileView(),
        '/change': (context) => ChangePasswordView(),
        '/manage': (context) => ManageUserView(),
      },
    );
  }
}
