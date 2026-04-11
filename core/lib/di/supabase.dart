import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnect {
  static final SupabaseConnect _instance = SupabaseConnect._internal();
  factory SupabaseConnect() {
    return _instance;
  }

  SupabaseConnect._internal();
  SupabaseClient? client;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://nxlvrhpjvbhpdphbgklq.supabase.co',
      anonKey: 'sb_publishable_RYXxtTiEqLXz0Xa_bnIN6g_3Y8rMkAJ',
    );

    client = Supabase.instance.client;
  }
}
