import 'package:app/partial/menu/menu.dart';
import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:test_module/test_module.dart';
import 'root/user_root.dart';
// import 'root/route_store_root.dart';

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
  late final List<AppState> moduleStack = [
    AppState(module: _getInitialModule()),
  ];
  late final Map<String, Widget Function()> moduleRegistry = {
    'USER': () => UserRoot().build(handleOutput),
    'USER_PROFILE': () => UserRoot().buildProfile(handleOutput),
    'USER_MANAGER_VIEW': () => UserRoot().buildManager(handleOutput),
    'TEST': () => const MyHomePage(title: 'Test Module'),
  };

  String _getInitialModule() {
    final user = storage.get<Map<String, dynamic>>('user');
    return user == null ? 'USER' : 'TEST';
  }

  void handleOutput(AppOutput output) {
    final payload = output.data;
    if (payload != null) {
      payload.forEach((k, v) => storage.set(k, v));
      if (payload.containsKey('id') && payload.containsKey('role')) {
        storage.set('user', payload);
      }
    }
    if (output.toModule == 'USER_PROFILE' &&
        (payload == null || !payload.containsKey('profile_user_id'))) {
      storage.remove('profile_user_id');
    }
    if (output.toModule != 'USER_PROFILE') {
      storage.remove('profile_user_id');
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
        drawer: Drawer(
          child: Menu(onOutput: handleOutput, currentModule: current.module),
        ),
        appBar: AppBar(title: const Text('App')),
        body: builder(),
      ),
    );
  }
}
