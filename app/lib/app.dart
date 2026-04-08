import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:user_module/output/user_output.dart';
import 'root/app_root.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentModule = 'USER';

  void handleOutput(UserOutput output) {
    if (output.type == 'LOGIN_SUCCESS') {
      final user = output.user!;

      // 👉 Lưu vào AppStorage (app làm, module không biết)
      final storage = get<AppStorage>();
      storage.userId = user.id;

      setState(() => currentModule = 'ORDER');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppRoot(currentModule: currentModule, onOutput: handleOutput),
    );
  }
}
