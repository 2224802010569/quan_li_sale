import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:test_module/test_module.dart';
import 'root/user_root.dart';
import 'root/route_store_root.dart';
// import thêm module mới ở đây
// import 'root/test_root.dart';

// void main() {
//   final storage = AppStorage();
//   put<AppStorage>(storage);

//   runApp(const MyApp());
// }

class AppState {
  final String module;
  AppState({required this.module});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppStorage storage = get<AppStorage>();

  /// chỉ quản lý module
  List<AppState> moduleStack = [AppState(module: 'USER')];

  /// registry
  late final Map<String, Widget Function()> moduleRegistry = {
    'USER': () => UserRoot().build(handleOutput),
    // 'ROUTE_STORE': () => RouteStoreRoot().build(handleOutput),
    'TEST': () => const MyHomePage(title: 'Test Module'),
  };

  /// handle output
  void handleOutput(AppOutput output) {
    if (output.data != null) {
      output.data!.forEach((k, v) => storage.set(k, v));
    }
    final current = moduleStack.last;
    if (current.module == output.toModule) return;
    setState(() {
      moduleStack.add(AppState(module: output.toModule));
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

    final builder =
        moduleRegistry[current.module] ??
        () => const Scaffold(body: Center(child: Text('Module không tồn tại')));

    return MaterialApp(home: builder());
  }
}
