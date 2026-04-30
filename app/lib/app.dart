import 'package:app/root/app_output.dart';
import 'package:app/partial/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:test_module/test_module.dart';
import 'root/user_root.dart';
import 'root/attendance_root.dart';
import 'root/inventory_root.dart';
import 'root/order_root.dart';
import 'root/route_store_root.dart';


class AppState {
  final String module;
  AppState(this.module);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = get<AppStorage>();
  final List<AppState> moduleStack = [];

  @override
  void initState() {
    super.initState();
    moduleStack.add(AppState(getInitialModule()));
  }

  // =========================
  // MODULE
  // =========================
  String getInitialModule() {
    // Luôn bắt đầu bằng màn hình đăng nhập
    return 'USER';
  }

  Widget getScreen(String module) {
    switch (module) {
      case 'USER':
        return UserRoot().build(handleOutput);

      case 'USER_PROFILE':
        return UserRoot().buildProfile(handleOutput);

      case 'USER_MANAGER_VIEW':
        return UserRoot().buildManager(handleOutput);

      case 'ATTENDANCE':
        return AttendanceRoot().build(handleOutput);

      case 'INVENTORY':
        return InventoryRoot().build(handleOutput);

      case 'ORDER':
        return OrderRoot().build(handleOutput);

      case 'CREATE_ORDER':
        return OrderRoot().buildCreate(handleOutput);

      case 'STORE_HOME':
        return RouteStoreRoot().buildStoreHome(handleOutput);

      case 'CHECKOUT':
        return AttendanceRoot().buildCheckout(handleOutput);

      case 'ROUTE_STORE':
        return RouteStoreRoot().build(handleOutput);

      case 'TEST':
        return const MyHomePage(title: 'Test Module');

      default:
        return const Scaffold(
          body: Center(child: Text('Module không tồn tại')),
        );
    }
  }

  // =========================
  // HANDLE OUTPUT
  // =========================
  void handleOutput(AppOutput output) {
    saveData(output.data);
    handleProfileLogic(output);

    final current = moduleStack.last.module;
    if (current == output.toModule) return;

    setState(() {
      moduleStack.add(AppState(output.toModule));
    });
  }

  void saveData(Map<String, dynamic>? data) {
    if (data == null) return;

    data.forEach((k, v) => storage.set(k, v));

    if (data.containsKey('id') && data.containsKey('role')) {
      storage.set('user', data);
    }
  }

  void handleProfileLogic(AppOutput output) {
    final data = output.data;

    if (output.toModule == 'USER_PROFILE') {
      if (data == null || !data.containsKey('profile_user_id')) {
        storage.remove('profile_user_id');
      }
    } else {
      storage.remove('profile_user_id');
    }
  }

  // =========================
  // BACK
  // =========================
  void handleBack() {
    if (moduleStack.length > 1) {
      setState(() {
        moduleStack.removeLast();
      });
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final current = moduleStack.last.module;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Drawer(
          child: Menu(onOutput: handleOutput, currentModule: current),
        ),
        appBar: AppBar(title: const Text('App')),
        body: getScreen(current),
      ),
    );
  }
}
