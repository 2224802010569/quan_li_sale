import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Đảm bảo đã import thư viện này

void main() async {
  await GlobalErrorReporter.runGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final supabase = SupabaseConnect();
      await supabase.init();

      put<SupabaseConnect>(supabase);

      final storage = AppStorage();
      await storage.init();
      put<AppStorage>(storage);

      runApp(ProviderScope(child: MyApp(key: appKey)));
    },
    config: const GlobalErrorReporterConfig(
      recoveryCallback: recoverFromGlobalError,
    ),
  );
}
