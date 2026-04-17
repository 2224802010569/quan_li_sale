import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? initError;

  try {
    // Lưu ý: Nếu pubspec.yaml cấu hình là - .env thì truyền fileName: ".env"
    // Nếu trong pubspec.yaml chứa - assets/.env thì truyền fileName: "assets/.env"
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  } catch (e) {
    print('\n=======================================');
    print('LỖI KHỞI TẠO: $e');
    print('=======================================\n');
    initError = e.toString();
  }

  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  final String? initError;
  const MyApp({Key? key, this.initError}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý Sale',
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: const Color(0xFF0F3c8f),
      ),
      home: initError != null ? InitErrorScreen(error: initError!) : const AuthWrapper(),
    );
  }
}

class InitErrorScreen extends StatelessWidget {
  final String error;
  const InitErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lỗi Khởi Tạo'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Hệ thống không thể kết nối tới cơ sở dữ liệu hoặc cấu hình biến môi trường bị lỗi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Vui lòng kiểm tra lại cấu hình pubspec.yaml và chắc chắn file .env đã được thêm vào mục assets.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.indigo, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

