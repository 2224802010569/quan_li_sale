import 'package:flutter/material.dart';
import 'package:user_module/output/login_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

import 'user_root.dart';
import 'route_store_root.dart';

class AppRoot extends StatelessWidget {
  final String currentModule;
  final String currentView;
  final Function(LoginOutput) onUserOutput;
  final VoidCallback onBack;

  const AppRoot({
    super.key,
    required this.currentModule,
    required this.currentView,
    required this.onUserOutput,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final storage = get<AppStorage>();

    final Map<String, Widget Function()> moduleRouter = {
      /// USER MODULE
      'USER': () => UserRoot.openLogin(onUserOutput),

      /// ROUTE STORE MODULE
      'ROUTE_STORE': () {
        final role = storage.get<String>('role') ?? '';
        return RouteStoreRoot.openHome(role, onBack);
      },
    };

    final builder = moduleRouter[currentModule];

    if (builder != null) {
      return builder();
    }

    return const Scaffold(body: Center(child: Text('Module không tồn tại')));
  }
}
