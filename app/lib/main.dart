import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabase = SupabaseConnect();
  await supabase.init();

  put<SupabaseConnect>(supabase);

  final storage = AppStorage();
  put<AppStorage>(storage);

  runApp(const MyApp());
}
