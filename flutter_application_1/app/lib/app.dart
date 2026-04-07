import 'package:flutter/material.dart';
import 'root/app_root.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentModule = 'USER';

  void handleOutput(String output) {
    if (output == 'GO_TO_USER') {
      setState(() => currentModule = 'USER');
    }

    if (output == 'GO_TO_ORDER') {
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
