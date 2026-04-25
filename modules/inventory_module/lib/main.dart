import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view/mock/inventory_mock_setup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Supabase (Sử dụng thông tin từ dự án của bạn)
  await Supabase.initialize(
    url: 'https://nxlvrhpjvbhpdphbgklq.supabase.co',
    anonKey: 'sb_publishable_RYXxtTiEqLXz0Xa_bnIN6g_3Y8rMkAJ',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Test Environment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      // 2. Đặt trang Mock làm màn hình chính
      home: const InventoryMockSetupView(),
    );
  }
}