import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabase = SupabaseConnect();
  await supabase.init();

  put<SupabaseConnect>(supabase);

  final storage = AppStorage();
  await storage.init();
  put<AppStorage>(storage);

  runApp(const ProviderScope(child: MyApp()));
}
