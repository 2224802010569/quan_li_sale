import 'package:app/partial/menu/menu.dart';
import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:test_module/test_module.dart';
import 'root/user_root.dart';
import 'root/route_store_root.dart';

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
  List<AppState> moduleStack = [AppState(module: 'USER')];
  late final Map<String, Widget Function()> moduleRegistry = {
    'USER': () => UserRoot().build(handleOutput),
    // 'ROUTE_STORE': () => RouteStoreRoot().build(handleOutput),
    'TEST': () => const MyHomePage(title: 'Test Module'),
  };

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Drawer(child: Menu(onOutput: handleOutput)),
        appBar: AppBar(title: const Text('App')),
        body: builder(),
      ),
    );
  }
}
