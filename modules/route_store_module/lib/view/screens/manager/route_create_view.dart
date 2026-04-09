import 'package:flutter/material.dart';

class RouteCreateView extends StatefulWidget {
  const RouteCreateView({super.key});

  @override
  State<RouteCreateView> createState() => _RouteCreateViewState();
}

class _RouteCreateViewState extends State<RouteCreateView> {
  final nameController = TextEditingController();

  void handleCreate() {
    final name = nameController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập tên tuyến')));
      return;
    }

    // demo: chỉ quay lại
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tuyến')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên tuyến'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: handleCreate, child: const Text('Lưu')),
          ],
        ),
      ),
    );
  }
}
