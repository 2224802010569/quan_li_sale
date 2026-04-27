import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/add_user_uc.dart';
import 'package:user_module/view/manager/widget/input_field.dart';

class AddUserView extends StatefulWidget {
  const AddUserView({super.key});

  @override
  State<AddUserView> createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final _uc = AddUserUC();

  String error = '';
  bool loading = false;

  Future<void> handleAdd() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final user = await _uc.execute(
        fullName: fullNameCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã tạo nhân viên. Username: ${user.username}, mật khẩu mặc định: 123456',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text('Thêm nhân viên')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140D47A1),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin nhân viên',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mã nhân viên, tài khoản, mật khẩu mặc định, vai trò Sale và group sẽ được tạo tự động.',
                    ),
                    const SizedBox(height: 24),
                    InputField(
                      label: 'HỌ TÊN',
                      controller: fullNameCtrl,
                      hint: 'Nguyen Van C',
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'EMAIL',
                      controller: emailCtrl,
                      hint: 'nhanvien@example.com',
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'SỐ ĐIỆN THOẠI',
                      controller: phoneCtrl,
                      hint: '0900000000',
                    ),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(error, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : handleAdd,
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Tạo nhân viên'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
