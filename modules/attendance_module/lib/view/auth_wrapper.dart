import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logic_uc/attendance_uc.dart';
import '../entity/user.dart' as entity_user;
import 'attendance_history_screen.dart';
import 'store_selection_screen.dart';

// --- DEV MODE CONFIGURATION ---
const bool isDevMode = false;
// Change this to test Manager vs Sale logic
const String mockUserId = 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d'; // Sale ID
// const String mockUserId = 'f5e4d3c2-b1a0-4f5e-bd9a-c8b7a6f5e4d3'; // Manager ID
// ------------------------------

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  User? _authUser;

  @override
  void initState() {
    super.initState();
    _authUser = Supabase.instance.client.auth.currentUser;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _authUser = data.session?.user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authUser == null && !isDevMode) {
      return const PlaceholderLoginScreen();
    }

    return FutureBuilder<entity_user.User>(
      future: _useCase.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F6FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0F3c8f)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Lỗi tải thông tin người dùng:\n${snapshot.error}'.replaceAll(
                    'Exception: ',
                    '',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy thông tin người dùng.')),
          );
        }

        final userRole = snapshot.data!.role;

        if (userRole == 'Manager') {
          return const AttendanceHistoryScreen();
        } else {
          // Default to Sale
          return const StoreSelectionScreen();
        }
      },
    );
  }
}

class PlaceholderLoginScreen extends StatelessWidget {
  const PlaceholderLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đăng nhập (Giả lập)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F3c8f),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFF0F3c8f)),
            const SizedBox(height: 24),
            const Text(
              'Bạn chưa đăng nhập.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Module Attendance sẽ được hiển thị khi User đã đăng nhập qua user_module.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // For test purposes, you would normally call signInWithPassword here.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Vui lòng sử dụng Form Login của user_module.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3c8f),
              ),
              child: const Text('Đi tới màn hình Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
