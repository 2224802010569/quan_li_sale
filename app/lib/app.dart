import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:user_module/output/login_output.dart';
import 'root/app_root.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<AppState> moduleStack = [AppState(module: 'USER', view: 'LOGIN')];

  final AppStorage storage = get<AppStorage>();

  void handleUserOutput(LoginOutput output) {
    final storage = get<AppStorage>();

    if (output.data != null) {
      output.data!.forEach((key, value) {
        storage.set(key, value);
      });
    }

    setState(() {
      moduleStack.add(AppState(module: output.to, view: output.view));
    });
  }

  void handleBack() {
    if (moduleStack.length > 1) {
      setState(() {
        moduleStack.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = moduleStack.last;
    return MaterialApp(
      home: AppRoot(
        currentModule: current.module,
        currentView: current.view,
        onUserOutput: handleUserOutput,
        onBack: handleBack,
      ),
    );
  }
}

class AppState {
  final String module;
  final String view;

  AppState({required this.module, required this.view});
}
