import 'package:flutter/material.dart';
import '../entity/store.dart';
import '../logic_uc/attendance_uc.dart';
import 'camera_action_screen.dart';

import 'sale_attendance_history_screen.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({Key? key}) : super(key: key);

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  List<Store> _stores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final stores = await _useCase.getSortedStores();
      if (mounted) {
        setState(() {
          _stores = stores;
          _isLoading = false;
        });
        print('\n--- DEV MODE DEBUG ---');
        print('Tìm thấy ${_stores.length} cửa hàng cho user tuyến này!');
        print('----------------------\n');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Danh sách Cửa hàng', style: TextStyle(color: Color(0xFF0F3c8f))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF0F3c8f)),
            tooltip: 'Lịch sử Check-in',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaleAttendanceHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Lỗi: $_error", textAlign: TextAlign.center)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    return Opacity(
                      opacity: store.isCompleted ? 0.5 : 1.0,
                      child: Card(
                        child: ListTile(
                          title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            store.isCompleted ? 'Đã hoàn thành' : 'Tuyến: ${store.route}',
                            style: TextStyle(color: store.isCompleted ? Colors.green : null),
                          ),
                          trailing: Icon(
                            store.isCompleted ? Icons.check_circle : Icons.camera_alt,
                            color: store.isCompleted ? Colors.green : const Color(0xFF0F3c8f),
                          ),
                          onTap: store.isCompleted
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CameraActionScreen(store: store),
                                    ),
                                  );
                                },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
